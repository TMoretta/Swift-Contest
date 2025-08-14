import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { decode } from 'https://deno.land/std@0.208.0/encoding/base64.ts'
import { corsHeaders } from '../_shared/cors.ts'

// Interfaces for incoming data
interface Place {
  id: string;
  address: string;
  lat: number;
  lon: number;
}

interface Contest {
  id: string;
  name: string;
  description: string;
  date_time: string;
  works_submission_start: string;
  works_submission_end: string;
}

interface ImagePayload {
  name: string;    // Original file name from the client, e.g., "my-photo.jpg"
  content: string; // Base64 encoded content
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

  const newlyUploadedPaths: string[] = []
  let oldImagePaths: string[] = []

  // Supabase client with admin privileges
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    const { contest, place, images } = await req.json() as {
      contest: Contest,
      place: Place,
      images?: ImagePayload[] // images are optional
    }

    // Verify the user performing the operation
    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.")
    }

    // --- TRANSACTION START ---

    // 1. Fetch the current contest to verify ownership before any writes.
    const { data: currentContest, error: fetchError } = await supabaseClient
      .from('contests')
      .select('images_paths, organizer_id, place_id')
      .eq('id', contest.id)
      .single()

    if (fetchError) throw new Error(`Failed to fetch current contest: ${fetchError.message}`)
    if (currentContest.organizer_id !== user.id) throw new Error("Forbidden: User is not the organizer of this contest.")

    // Prepare the payload for updating the contest table.
    // Only include fields that are safe to update from client input.
    const contestUpdatePayload: { [key: string]: any } = {
      name: contest.name,
      description: contest.description,
      date_time: contest.date_time,
      works_submission_start: contest.works_submission_start,
      works_submission_end: contest.works_submission_end,
    };

    // 2. If new images are provided, handle the upload process.
    if (images && images.length > 0) {
      oldImagePaths = currentContest.images_paths || []
      const finalImagePaths: string[] = []

      // Upload new images BEFORE updating the database.
      for (const image of images) {
        const fileContent = decode(image.content)
        // Generate a unique path on the server.
        const finalUploadPath = `${contest.id}/${crypto.randomUUID()}/${image.name}`

        const { error: uploadError } = await supabaseClient.storage
          .from('contests-images')
          .upload(finalUploadPath, fileContent, {
            contentType: getMimeType(image.name),
            upsert: false,
          })

        if (uploadError) {
          throw new Error(`Image upload error for ${image.name}: ${uploadError.message}`)
        }
        newlyUploadedPaths.push(finalUploadPath)
        finalImagePaths.push(finalUploadPath)
      }
      // Add the new image URLs to the update payload.
      contestUpdatePayload.images_paths = finalImagePaths
    }

    // 3. Update the Place in the database.
    const { error: placeError } = await supabaseClient
      .from('places')
      .update({ address: place.address, lat: place.lat, lon: place.lon })
      .eq('id', currentContest.place_id)

    if (placeError) throw new Error(`Place update error: ${placeError.message}`)

    // 4. Update the Contest in the database with the prepared payload.
    const { data: updatedContestData, error: contestError } = await supabaseClient
      .from('contests')
      .update(contestUpdatePayload)
      .eq('id', contest.id)
      .select()
      .single()

    if (contestError) throw new Error(`Contest update error: ${contestError.message}`)

    // 5. If everything was successful, clean up the old images (if new ones were uploaded).
    if (oldImagePaths.length > 0) {
      const { error: deleteError } = await supabaseClient.storage
        .from('contests-images')
        .remove(oldImagePaths)

      if (deleteError) {
        // Don't block the request for this, but log it as it requires manual intervention.
        console.error(`CRITICAL: Failed to delete old images: ${oldImagePaths.join(', ')}. Error: ${deleteError.message}`)
      }
    }

    // --- FINE TRANSAZIONE ---

    // 6. Success: return the updated contest.
    return new Response(JSON.stringify(updatedContestData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200, // 200 OK
    })

  } catch (error) {
    // --- ROLLBACK ON ERROR ---
    console.error("Error during contest update, starting rollback...", error)

    // If new images were uploaded before the failure, delete them.
    if (newlyUploadedPaths.length > 0) {
      await supabaseClient.storage.from('contests-images').remove(newlyUploadedPaths)
    }

    // Return a generic error response to the client.
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})