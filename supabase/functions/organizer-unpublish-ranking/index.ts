import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { contest_ranking_id } = await req.json()

    if (!contest_ranking_id) {
      throw new Error("Missing 'contest_ranking_id' in request body.")
    }

    // 1. Creare un client Supabase con i permessi dell'utente che fa la chiamata
    const userSupabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user } } = await userSupabaseClient.auth.getUser()
    if (!user) {
      throw new Error("User not authenticated.")
    }

    // 2. Creare un client Supabase con privilegi di amministratore per le operazioni
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // --- INIZIO TRANSAZIONE ---

    // 3. Recuperare i dati della classifica e verificare i permessi
    const { data: rankingData, error: fetchError } = await supabaseAdmin
      .from('contest_rankings')
      .select(`
        file_path,
        contest:contests ( organizer_id )
      `)
      .eq('id', contest_ranking_id)
      .single()

    if (fetchError) {
      throw new Error(`Ranking not found or failed to fetch: ${fetchError.message}`)
    }

    // Verifica di sicurezza: l'utente è l'organizzatore del contest?
    if (rankingData.contest?.organizer_id !== user.id) {
      return new Response(JSON.stringify({ error: 'User is not authorized to unpublish this ranking.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 403, // 403 Forbidden
      })
    }

    const filePathToDelete = rankingData.file_path;

    // 4. Eliminare la riga dal database PRIMA
    const { error: dbDeleteError } = await supabaseAdmin
      .from('contest_rankings')
      .delete()
      .eq('id', contest_ranking_id)

    if (dbDeleteError) {
      throw new Error(`Failed to delete ranking from database: ${dbDeleteError.message}`)
    }

    // 5. Se la cancellazione dal DB ha successo, eliminare il file dallo storage
    if (filePathToDelete) {
      const { error: storageError } = await supabaseAdmin
        .storage
        .from('contests-rankings') // Assicurati che il nome del bucket sia corretto
        .remove([filePathToDelete])

      if (storageError) {
        // Non bloccare la richiesta, ma logga un errore critico per un intervento manuale
        console.error(`CRITICAL: Failed to delete orphaned file from storage: ${filePathToDelete}. Error: ${storageError.message}`)
      }
    }

    // --- FINE TRANSAZIONE ---

    // 6. Successo: restituisci una risposta vuota
    return new Response(null, {
      headers: { ...corsHeaders },
      status: 204, // 204 No Content
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})