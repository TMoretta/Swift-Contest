import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { decode } from 'https://deno.land/std@0.208.0/encoding/base64.ts'
import { corsHeaders } from '../_shared/cors.ts'

// Interfacce per i dati in ingresso
interface Work {
  title: string;
  description: string;
  images_urls: string[]; // Questo verrà ricalcolato sul server
  // ...altri campi del work
}

interface ImagePayload {
  path: string; // Path parziale dal client, es: "uuid/nome.jpg"
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

  let workId: string | null = null
  const uploadedImagePaths: string[] = []

  // Client Supabase con privilegi di amministratore
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    const { p_contest_id, p_work, p_images } = await req.json() as {
      p_contest_id: string,
      p_work: Work,
      p_images: ImagePayload[]
    }

    // Verifica l'utente (partecipante) che sta eseguendo l'operazione
    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.")
    }

    // --- INIZIO TRANSAZIONE ---

    // 2. Trova l'ID della partecipazione per questo utente e contest
    const { data: participationData, error: participationError } = await supabaseClient
      .from('participations')
      .select('id')
      .eq('contest_id', p_contest_id)
      .eq('participant_id', user.id)
      .single();

    if (participationError) throw new Error(`Error fetching participation: ${participationError.message}`);
    if (!participationData) throw new Error('User is not registered as a participant in this contest.');

    const participationId = participationData.id;

    const workToInsert = {
      ...p_work,
      participation_id: participationId
    }

    const { data: workData, error: workError } = await supabaseClient
      .from('works') // Assicurati che il nome della tabella sia 'works'
      .insert(workToInsert)
      .select('id')
      .single()

    if (workError) throw new Error(`Work insert error: ${workError.message}`)
    workId = workData.id

    // 2. Carica le immagini con il path corretto e raccogli gli URL finali
    const finalImageUrls: string[] = []
    // Assumo che il bucket per le opere si chiami 'works-images'
    const bucketName = 'works-images';

    for (const image of p_images) {
      const fileContent = decode(image.content)

      const { error: uploadError } = await supabaseClient.storage
        .from(bucketName)
        .upload(image.path, fileContent, {
          contentType: getMimeType(image.path),
          upsert: false,
        })

      if (uploadError) {
        throw new Error(`Image upload error for ${image.path}: ${uploadError.message}`)
      }

      uploadedImagePaths.push(image.path) // Per il rollback
      finalImageUrls.push(image.path) // Per l'update finale
    }

    // --- FINE TRANSAZIONE ---

    // 4. Successo
    return new Response(null, {
      headers: { ...corsHeaders },
      status: 204, // 204 No Content
    })

  } catch (error) {
    // --- ROLLBACK IN CASO DI ERRORE ---
    console.error("Error during work submission, starting rollback...", error)

    if (uploadedImagePaths.length > 0) {
      await supabaseClient.storage.from('works-images').remove(uploadedImagePaths)
    }
    if (workId) {
      await supabaseClient.from('works').delete().eq('id', workId)
    }

    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})