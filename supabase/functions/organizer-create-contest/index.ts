import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

serve(async (req) => {
  // Gestione della richiesta pre-flight CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Leggiamo il body della richiesta all'inizio, così è disponibile anche nel blocco catch.
  let requestBody;
  try {
    requestBody = await req.json();
  } catch (e) {
    return new Response(JSON.stringify({ error: 'Invalid JSON body' }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    });
  }

  const { p_contest, p_place } = requestBody;

  try {
    // 1. Crea un client Supabase con l'autenticazione dell'utente.
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // 2. Chiama la RPC per creare il contest nel database.
    const { data: createdContest, error: rpcError } = await supabaseClient
      .rpc('organizer_create_contest', {
        p_contest: p_contest,
        p_place: p_place,
      })
      .single(); // .single() è importante per ottenere un oggetto, non un array

    // Se la RPC stessa ha restituito un errore, lancialo per attivare il blocco catch.
    if (rpcError) {
      throw rpcError;
    }

    // 3. Se tutto è andato a buon fine, restituisci i dati del contest appena creato.
    return new Response(JSON.stringify(createdContest), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 201, // 201 Created è più appropriato qui
    });

  } catch (error) {
    // --- LOGICA DI ROLLBACK ---
    console.error('Error during contest creation, starting rollback:', error.message);

    // Estrai i path delle immagini dalla richiesta originale.
    const imagePathsToDelete = p_contest?.images_urls;

    if (imagePathsToDelete && Array.isArray(imagePathsToDelete) && imagePathsToDelete.length > 0) {
      console.log(`Attempting to clean up ${imagePathsToDelete.length} orphaned images...`);

      // Crea un client con i permessi di amministratore per cancellare i file.
      const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      );

      // Tenta di rimuovere i file dallo storage.
      const { error: deleteError } = await supabaseAdmin.storage
        .from('contests-images')
        .remove(imagePathsToDelete);

      if (deleteError) {
        console.error('CRITICAL: Failed to delete orphaned images from storage:', deleteError.message);
        // A questo punto, hai file orfani. È importante loggare questo errore.
      } else {
        console.log('Orphaned images cleaned up successfully.');
      }
    }

    // Restituisci una risposta di errore al client.
    return new Response(JSON.stringify({ error: `Contest creation failed: ${error.message}` }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
})