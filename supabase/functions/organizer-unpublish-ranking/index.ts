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

    // 1. Create a client to verify the user's identity from the auth header.
    const userSupabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    const { data: { user } } = await userSupabaseClient.auth.getUser()
    if (!user) {
      throw new Error("User not authenticated.")
    }

    // 2. Create an admin client to perform privileged operations.
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // --- TRANSACTION START ---

    // 3. Fetch the ranking data and verify permissions.
    const { data: rankingData, error: fetchError } = await supabaseAdmin
      .from('contest_rankings')
      .select(`
        file_path,
        contest:contests ( organizer_id )
      `)
      .eq('id', contest_ranking_id)
      .single()

    if (fetchError || !rankingData) {
      // Handle both query errors and cases where the ranking ID does not exist.
      throw new Error(`Ranking not found or failed to fetch.`)
    }

    // Security Check: Is the user the organizer of the contest?
    if (rankingData.contest?.organizer_id !== user.id) { // The ?. is for type safety
      return new Response(JSON.stringify({ error: 'User is not authorized to unpublish this ranking.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 403, // 403 Forbidden
      })
    }

    const filePathToDelete = rankingData.file_path;

    // 4. Delete the database row FIRST.
    const { error: dbDeleteError } = await supabaseAdmin
      .from('contest_rankings')
      .delete()
      .eq('id', contest_ranking_id)

    if (dbDeleteError) {
      throw new Error(`Failed to delete ranking from database: ${dbDeleteError.message}`)
    }

    // 5. If the DB deletion is successful, delete the file from storage.
    if (filePathToDelete) {
      const { error: storageError } = await supabaseAdmin
        .storage
        .from('contests-rankings') // Ensure bucket name is correct
        .remove([filePathToDelete])

      if (storageError) {
        // Don't block the request, but log a critical error for manual intervention.
        console.error(`CRITICAL: Failed to delete orphaned file from storage: ${filePathToDelete}. Error: ${storageError.message}`)
      }
    }

    // --- TRANSACTION END ---

    // 6. Success: return an empty response.
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