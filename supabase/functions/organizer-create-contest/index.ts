import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { decode } from 'https://deno.land/std@0.208.0/encoding/base64.ts'
import { corsHeaders } from '../_shared/cors.ts'

// Definiamo le interfacce per un type-checking migliore
interface Place {
  address: string;
  lat: number;
  lon: number;
}

interface Contest {
  name: string;
  description: string;
  images_urls: string[];
  // ...tutti gli altri campi
}

interface ImagePayload {
  path: string; // Path parziale dal client, es: "uuid/nome.jpg"
  content: string; // Base64 encoded
}

// Funzione helper per ottenere il MIME type dall'estensione del file
const getMimeType = (fileName: string): string => {
  const extension = fileName.split('.').pop()?.toLowerCase();
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    default:
      // Un tipo generico per file binari se non riconosciuto
      return 'application/octet-stream';
  }
};


Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  let placeId: string | null = null
  let contestId: string | null = null
  const uploadedImagePaths: string[] = []

  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    const { p_contest, p_place, p_images } = await req.json() as {
      p_contest: Contest,
      p_place: Place,
      p_images: ImagePayload[]
    }

    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.")
    }

    // --- INIZIO TRANSAZIONE ---

    // 1. Inserisci il luogo (Place)
    const { data: placeData, error: placeError } = await supabaseClient
      .from('places')
      .insert(p_place)
      .select('id')
      .single()

    if (placeError) throw new Error(`Place insert error: ${placeError.message}`)
    placeId = placeData.id

    // 2. Inserisci il contest (inizialmente con images_urls vuoto)
    const contestToInsert = {
      ...p_contest,
      images_urls: [], // Verrà aggiornato dopo l'upload
      place_id: placeId,
      organizer_id: user.id,
    }

    const { data: contestData, error: contestError } = await supabaseClient
      .from('contests')
      .insert(contestToInsert)
      .select('id') // Prendiamo solo l'ID per ora
      .single()

    if (contestError) throw new Error(`Contest insert error: ${contestError.message}`)
    contestId = contestData.id

    // 3. Carica le immagini con il path corretto e raccogli gli URL finali
    const finalImageUrls: string[] = []
    for (const image of p_images) {
      const fileContent = decode(image.content)

      const clientPath = image.path.startsWith('null/') ? image.path.substring(5) : image.path
      const finalUploadPath = `${contestId}/${clientPath}`

      // *** MODIFICA CHIAVE: Aggiungiamo il Content-Type corretto ***
      const { error: uploadError } = await supabaseClient.storage
        .from('contests-images')
        .upload(finalUploadPath, fileContent, {
          upsert: false,
          contentType: getMimeType(finalUploadPath),
        })

      if (uploadError) {
        throw new Error(`Image upload error for ${finalUploadPath}: ${uploadError.message}`)
      }

      uploadedImagePaths.push(finalUploadPath) // Per il rollback
      finalImageUrls.push(finalUploadPath) // Per l'update finale
    }

    // 4. Aggiorna il contest con gli URL delle immagini corrette
    const { data: updatedContestData, error: updateError } = await supabaseClient
      .from('contests')
      .update({ images_urls: finalImageUrls })
      .eq('id', contestId)
      .select()
      .single()

    if (updateError) {
      throw new Error(`Contest update error: ${updateError.message}`)
    }

    // --- FINE TRANSAZIONE ---

    // 5. Successo: restituisci il contest completo e aggiornato
    return new Response(JSON.stringify(updatedContestData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 201,
    })

  } catch (error) {
    // --- ROLLBACK IN CASO DI ERRORE ---
    console.error("Error during contest creation, starting rollback...", error)

    if (uploadedImagePaths.length > 0) {
      await supabaseClient.storage.from('contests-images').remove(uploadedImagePaths)
    }
    if (contestId) {
      await supabaseClient.from('contests').delete().eq('id', contestId)
    }
    if (placeId) {
      await supabaseClient.from('places').delete().eq('id', placeId)
    }

    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})