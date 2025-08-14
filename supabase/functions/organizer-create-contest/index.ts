import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { decode } from 'https://deno.land/std@0.208.0/encoding/base64.ts'
import { corsHeaders } from '../_shared/cors.ts'

// Define interfaces for better type-checking
interface Place {
  address: string;
  lat: number;
  lon: number;
}

interface Contest {
  name: string;
  description: string;
  date_time: string;
  works_submission_start: string;
  works_submission_end: string;
}

interface ImagePayload {
  name: string;   // Original file name from the client, e.g., "my-photo.jpg"
  content: string; // Base64 encoded
}

// Helper function to get the MIME type from the file extension
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
      return 'application/octet-stream'; // A generic binary type if unrecognized
  }
};


Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  let placeId: string | null = null
  let contestId: string | null = null
  const uploadedImagePaths: string[] = []

  // Use the service role key to perform admin-level operations.
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    const { contest, place, images } = await req.json() as {
      contest: Contest,
      place: Place,
      images: ImagePayload[]
    }

    // Get the user from the authorization header.
    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.")
    }

    // --- TRANSACTION START ---

    // 1. Insert the Place
    const { data: placeData, error: placeError } = await supabaseClient
      .from('places')
      .insert(place)
      .select('id')
      .single()

    if (placeError) throw new Error(`Place insert error: ${placeError.message}`)
    placeId = placeData.id

    // 2. Insert the contest (initially with empty images_paths)
    const contestToInsert = {
      ...contest,
      images_paths: [], // Will be updated after the image uploads
      place_id: placeId,
      organizer_id: user.id,
    }

    const { data: contestData, error: contestError } = await supabaseClient
      .from('contests')
      .insert(contestToInsert)
      .select('id') // Get the ID for the next steps
      .single()

    if (contestError) throw new Error(`Contest insert error: ${contestError.message}`)
    contestId = contestData.id

    // 3. Upload images with the correct server-generated path and collect the final URLs
    const finalImagePaths: string[] = []
    for (const image of images) {
      const fileContent = decode(image.content)

      // Generate a unique path on the server to prevent collisions.
      // Format: {contest_id}/{uuid}/{original_file_name}
      const finalUploadPath = `${contestId}/${crypto.randomUUID()}/${image.name}`

      // Upload the file with the correct content type.
      const { error: uploadError } = await supabaseClient.storage
        .from('contests-images')
        .upload(finalUploadPath, fileContent, {
          upsert: false,
          contentType: getMimeType(finalUploadPath),
        })

      if (uploadError) {
        throw new Error(`Image upload error for ${finalUploadPath}: ${uploadError.message}`)
      }

      uploadedImagePaths.push(finalUploadPath) // For rollback
      finalImagePaths.push(finalUploadPath) // For the final update
    }

    // 4. Update the contest with the correct image URLs
    const { data: updatedContestData, error: updateError } = await supabaseClient
      .from('contests')
      .update({ images_paths: finalImagePaths })
      .eq('id', contestId)
      .select()
      .single()

    if (updateError) {
      throw new Error(`Contest update error: ${updateError.message}`)
    }

    // --- TRANSACTION END ---

    // 5. Success: return the complete and updated contest
    return new Response(JSON.stringify(updatedContestData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 201,
    })

  } catch (error) {
    // --- ROLLBACK ON ERROR ---
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