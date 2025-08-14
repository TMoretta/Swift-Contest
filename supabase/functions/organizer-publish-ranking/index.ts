import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { decode } from 'https://deno.land/std@0.208.0/encoding/base64.ts'
import { corsHeaders } from '../_shared/cors.ts'

// Interface for the incoming request body
interface ContestRankingPayload {
  contest_id: string
  file_name: string // The original name of the file
  file: string // base64 encoded
}

Deno.serve(async (req) => {
  // This is needed if you're planning to invoke your function from a browser.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  let uploadedFilePath: string | null = null;

  try {
    const { contest_id, file_name, file }: ContestRankingPayload = await req.json()

    // Create a Supabase client with the service role key to bypass RLS
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      // Chose 'false' as we don't need to persist the session server-side.
      { auth: { persistSession: false } }
    )

    // Get the user from the authorization header to verify permissions.
    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.")
    }

    // SECURITY: Verify that the user is the organizer of the contest.
    const { data: contest, error: contestError } = await supabaseAdmin
      .from('contests')
      .select('organizer_id')
      .eq('id', contest_id)
      .single();

    if (contestError || !contest) {
      throw new Error("Contest not found.");
    }
    if (contest.organizer_id !== user.id) {
      return new Response(JSON.stringify({ error: "Forbidden: You are not the organizer of this contest." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 403,
      });
    }

    // Sanitize base64 string by removing potential data URI prefix
    const sanitizedBase64 = file.split(',').pop() ?? ''
    if (!sanitizedBase64) {
      throw new Error('File content is empty or invalid.')
    }
    const fileData = decode(sanitizedBase64)

    // Generate a unique file path on the server to prevent collisions.
    const finalFilePath = `${contest_id}/${crypto.randomUUID()}/${file_name}`

    // 1. Upload file to storage using the admin client
    const { error: uploadError } = await supabaseAdmin.storage
      .from('contests-rankings')
      .upload(finalFilePath, fileData, {
        contentType: 'application/pdf', // Or derive from file name if needed
        upsert: false, // Don't allow overwriting
      })

    if (uploadError) {
      throw new Error(`Storage upload error: ${uploadError.message}`)
    }
    uploadedFilePath = finalFilePath; // Track for potential rollback

    // 2. Insert into database using the admin client
    const { error: dbError } = await supabaseAdmin.from('contest_rankings').insert({
      contest_id: contest_id,
      file_path: finalFilePath,
    })

    if (dbError) {
      // If database insert fails, delete the uploaded file to prevent orphans
      await supabaseAdmin.storage.from('contests-rankings').remove([finalFilePath])
      throw new Error(`Database insert error: ${dbError.message}`)
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    // If an error occurred and a file was uploaded, attempt to roll it back.
    if (uploadedFilePath) {
      const supabaseAdmin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
      await supabaseAdmin.storage.from('contests-rankings').remove([uploadedFilePath]);
    }
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})