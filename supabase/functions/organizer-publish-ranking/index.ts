import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.0.0'
import { decode } from 'https://deno.land/std@0.168.0/encoding/base64.ts'
import { corsHeaders } from '../_shared/cors.ts'

interface ContestRanking {
  contest_id: string
  file_path: string
  file: string // base64 encoded
}

serve(async (req) => {
  // This is needed if you're planning to invoke your function from a browser.
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { contest_id, file_path, file }: ContestRanking = await req.json()

    // Create a Supabase client with the service role key to bypass RLS
    const adminClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      // Chose 'false' as we don't need to persist the session server-side.
      { auth: { persistSession: false } }
    )

    // Sanitize base64 string by removing potential data URI prefix
    const sanitizedBase64 = file.split(',').pop() ?? ''
    if (!sanitizedBase64) {
      throw new Error('File content is empty or invalid.')
    }

    const fileData = decode(sanitizedBase64)

    // 1. Upload file to storage using the admin client
    const { error: uploadError } = await adminClient.storage
      .from('contests-rankings')
      .upload(filePath, fileData, {
        contentType: 'application/pdf', // Or derive from file name if needed
        upsert: true,
      })

    if (uploadError) {
      throw new Error(`Storage upload error: ${uploadError.message}`)
    }

    // 2. Insert into database using the admin client
    const { error: dbError } = await adminClient.from('contest_rankings').insert({
      contest_id: contest_id,
      file_path: file_path,
    })

    if (dbError) {
      // If database insert fails, delete the uploaded file to prevent orphans
      await adminClient.storage.from('contests-rankings').remove([filePath])
      throw new Error(`Database insert error: ${dbError.message}`)
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})