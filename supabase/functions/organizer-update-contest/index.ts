import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { decode } from 'https://deno.land/std@0.208.0/encoding/base64.ts'
import { corsHeaders } from '../_shared/cors.ts'

// Interfacce per i dati in ingresso
interface Place {
  id: string;
  address: string;
  lat: number;
  lon: number;
}

interface Contest {
  id: string;
  place_id: string;
  name: string;
  description: string;
  images_urls: string[];
  // ...tutti gli altri campi del contest
}

interface ImagePayload {
  path: string; // Path completo, es: "contest-id/uuid/nome.jpg"
  content: string; // Contenuto Base64
}

// Funzione helper per dedurre il MIME type dall'estensione
const getMimeType = (fileName: string): string => {
  const extension = fileName.split('.').pop()?.toLowerCase();
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    default:
      return 'application/octet-stream';
  }
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const newlyUploadedPaths: string[] = []
  let oldImageUrls: string[] = []

  // Client Supabase con privilegi di amministratore
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    const { p_contest, p_place, p_images } = await req.json() as {
      p_contest: Contest,
      p_place: Place,
      p_images?: ImagePayload[] // p_images è opzionale
    }

    // Verifica l'utente che sta eseguendo l'operazione
    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.")
    }

    // --- INIZIO TRANSAZIONE ---

    // 1. Se si aggiornano le immagini, recupera la lista delle vecchie immagini per la pulizia finale
    if (p_images && p_images.length > 0) {
      const { data: currentContest, error: fetchError } = await supabaseClient
        .from('contests')
        .select('images_urls, organizer_id')
        .eq('id', p_contest.id)
        .single()

      if (fetchError) throw new Error(`Failed to fetch current contest: ${fetchError.message}`)
      if (currentContest.organizer_id !== user.id) throw new Error("User is not the organizer of this contest.")

      oldImageUrls = currentContest.images_urls || []

      // 2. Carica le nuove immagini PRIMA di toccare il DB
      for (const image of p_images) {
        const fileContent = decode(image.content)
        const { error: uploadError } = await supabaseClient.storage
          .from('contests-images')
          .upload(image.path, fileContent, {
            contentType: getMimeType(image.path),
            upsert: false,
          })

        if (uploadError) {
          throw new Error(`Image upload error for ${image.path}: ${uploadError.message}`)
        }
        newlyUploadedPaths.push(image.path)
      }
    }

    // 3. Aggiorna il luogo (Place) nel database
    const { error: placeError } = await supabaseClient
      .from('places')
      .update({ address: p_place.address, lat: p_place.lat, lon: p_place.lon })
      .eq('id', p_contest.place_id)

    if (placeError) throw new Error(`Place update error: ${placeError.message}`)

    // 4. Aggiorna il contest nel database
    // Se p_images non è stato fornito, p_contest.images_urls conterrà le vecchie URL, non modificandole.
    // Se p_images è stato fornito, p_contest.images_urls conterrà le NUOVE URL, aggiornando il campo.
    const { data: updatedContestData, error: contestError } = await supabaseClient
      .from('contests')
      .update(p_contest)
      .eq('id', p_contest.id)
      .select()
      .single()

    if (contestError) throw new Error(`Contest update error: ${contestError.message}`)

    // 5. Se tutto è andato a buon fine, pulisci le vecchie immagini (se ne sono state caricate di nuove)
    if (oldImageUrls.length > 0) {
      const { error: deleteError } = await supabaseClient.storage
        .from('contests-images')
        .remove(oldImageUrls)

      if (deleteError) {
        // Non bloccare la richiesta per questo, ma logga l'errore perché richiede un intervento manuale
        console.error(`CRITICAL: Failed to delete old images: ${oldImageUrls.join(', ')}. Error: ${deleteError.message}`)
      }
    }

    // --- FINE TRANSAZIONE ---

    // 6. Successo: restituisci il contest aggiornato
    return new Response(JSON.stringify(updatedContestData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200, // 200 OK
    })

  } catch (error) {
    // --- ROLLBACK IN CASO DI ERRORE ---
    console.error("Error during contest update, starting rollback...", error)

    // Se sono state caricate nuove immagini prima del fallimento, eliminale
    if (newlyUploadedPaths.length > 0) {
      await supabaseClient.storage.from('contests-images').remove(newlyUploadedPaths)
    }

    // Restituisci una risposta di errore generica al client
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})