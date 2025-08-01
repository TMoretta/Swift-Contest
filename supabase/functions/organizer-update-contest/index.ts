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

    // 2. Chiama la RPC per aggiornare il contest nel database.
    const { data: updatedContest, error: rpcError } = await supabaseClient
      .rpc('organizer_update_contest', {
        p_contest: p_contest,
        p_place: p_place,
      })
      .single();

    // Se la RPC stessa ha restituito un errore, lancialo per attivare il blocco catch.
    if (rpcError) {
      throw rpcError;
    }

    // 3. Se tutto è andato a buon fine, restituisci i dati del contest aggiornato.
    return new Response(JSON.stringify(updatedContest), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200, // 200 OK è appropriato per un update
    });

  } catch (error) {
    // --- LOGICA DI ROLLBACK ---
    console.error('Error during contest update, starting rollback:', error.message);

    // Estrai i path delle immagini dalla richiesta originale.
    // Questi sono i path delle NUOVE immagini che potrebbero essere state caricate.
    const imagePathsToDelete = p_contest?.images_urls;

    if (imagePathsToDelete && Array.isArray(imagePathsToDelete) && imagePathsToDelete.length > 0) {
      console.log(`Attempting to clean up ${imagePathsToDelete.length} potentially orphaned images...`);
      
      // Crea un client con i permessi di amministratore per cancellare i file.
      const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      );

      // Tenta di rimuovere i file dallo storage.
      const { error: deleteError } = await supabaseAdmin.storage
        .from('contests-images') // Assicurati che il nome del bucket sia corretto
        .remove(imagePathsToDelete);

      if (deleteError) {
        console.error('CRITICAL: Failed to delete orphaned images from storage during update rollback:', deleteError.message);
      } else {
        console.log('Orphaned images cleaned up successfully.');
      }
    }

    // Restituisci una risposta di errore al client.
    return new Response(JSON.stringify({ error: `Contest update failed: ${error.message}` }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
})