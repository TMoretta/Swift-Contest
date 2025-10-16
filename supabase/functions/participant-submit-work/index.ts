import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { decode } from 'https://deno.land/std@0.208.0/encoding/base64.ts'
import { corsHeaders } from '../_shared/cors.ts'

// Interfaces for incoming data
interface WorkPayload {
  name: string;
  description: string;
}

interface ImagePayload {
  name: string;    // Original file name from the client, e.g., "my-photo.jpg"
  content: string; // Base64 encoded content
}

// NEW: Interface for the single file payload
interface FilePayload {
  name: string;
  content: string;
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
      return 'application/octet-stream';
  }
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  let workId: string | null = null
  const uploadedImagePaths: string[] = []
  let uploadedFilePath: string | null = null; // NEW: For file rollback

  // Supabase client with admin privileges
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  try {
    // UPDATED: Destructure 'file' from the request body
    const { contest_id, work, images, file } = await req.json() as {
      contest_id: string,
      work: WorkPayload,
      images: ImagePayload[],
      file: FilePayload
    }

    // Verify the user (participant) performing the operation
    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.")
    }

    // --- TRANSACTION START ---

    // 1. Fetch contest details to check submission dates.
    const { data: contestData, error: contestError } = await supabaseClient
      .from('contests')
      .select('works_submission_start, works_submission_end, organizer_id, name')
      .eq('id', contest_id)
      .single();

    if (contestError || !contestData) throw new Error('Contest not found.');

    // 2. KEY CHECK: Verify that the current date is within the submission period.
    const now = new Date();
    const submissionStart = new Date(contestData.works_submission_start);
    const submissionEnd = new Date(contestData.works_submission_end);
    if (now < submissionStart || now > submissionEnd) {
      throw new Error('The submission period for works is not active.');
    }

    // 3. Find the user's participation record for this contest.
    const { data: participationData, error: participationError } = await supabaseClient
      .from('participations')
      .select('id, has_submitted')
      .eq('contest_id', contest_id)
      .eq('participant_id', user.id)
      .single();

    if (participationError) throw new Error(`Error fetching participation: ${participationError.message}`);
    if (!participationData) throw new Error('You are not a participant in this contest.');

    // 4. Check if the user has already submitted a work.
    if (participationData.has_submitted) {
      throw new Error('You have already submitted a work for this contest.');
    }

    const participationId = participationData.id;

    // 5. Create the new record in the 'works' table.
    // NOTE: Assumes you have added a 'file_path' TEXT column to your 'works' table.
    const workToInsert = {
      participation_id: participationId,
      name: work.name,
      description: work.description,
      images_paths: [], // Will be updated after upload
      file_path: '',    // Will be updated after upload
    }

    const { data: workData, error: workError } = await supabaseClient
      .from('works')
      .insert(workToInsert)
      .select('id')
      .single()

    if (workError || !workData) throw new Error(`Work insert error: ${workError?.message ?? 'No data returned'}`)
    workId = workData.id

    // 6. Upload files
    // 6a. NEW: Upload the main work file (ZIP)
    const fileBucketName = 'works-files';
    const fileContent = decode(file.content);
    const finalFilePath = `${contest_id}/${workId}/${crypto.randomUUID()}/${file.name}`;

    const { error: fileUploadError } = await supabaseClient.storage
      .from(fileBucketName)
      .upload(finalFilePath, fileContent, {
        contentType: 'application/zip',
        upsert: false,
      });

    if (fileUploadError) {
      throw new Error(`File upload error for ${file.name}: ${fileUploadError.message}`);
    }
    uploadedFilePath = finalFilePath; // For rollback

    // 6b. Upload images with the correct server-generated path
    const finalImagePaths: string[] = []
    const imageBucketName = 'works-images';

    for (const image of images) {
      const imageContent = decode(image.content)
      const finalUploadPath = `${contest_id}/${workId}/${crypto.randomUUID()}/${image.name}`

      const { error: uploadError } = await supabaseClient.storage
        .from(imageBucketName)
        .upload(finalUploadPath, imageContent, {
          contentType: getMimeType(image.name),
          upsert: false,
        })

      if (uploadError) {
        throw new Error(`Image upload error for ${image.name}: ${uploadError.message}`)
      }

      uploadedImagePaths.push(finalUploadPath) // For rollback
      finalImagePaths.push(finalUploadPath) // For the final update
    }

    // 7. UPDATED: Update the 'works' table with all the final file paths.
    await supabaseClient.from('works').update({
        images_paths: finalImagePaths,
        file_path: finalFilePath
    }).eq('id', workId);

    // 8. Update the 'participations' table to mark the work as submitted.
    await supabaseClient.from('participations').update({ has_submitted: true }).eq('id', participationId);

    // 9. Create a notification message for the organizer.
    try {
      const { data: profileData } = await supabaseClient
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .single();

      if (profileData) {
        const participantName = profileData.full_name;
        const contestName = contestData.name;
        const organizerId = contestData.organizer_id;

        await supabaseClient
          .from('messages')
          .insert({
            account_id: organizerId,
            title: 'Work Submitted',
            body: `The participant "${participantName}" has submitted their work for your contest "${contestName}".`
          });
      }
    } catch (notificationError) {
      console.error("Failed to create notification message, but submission was successful:", notificationError.message);
    }

    // 10. Success
    return new Response(null, {
      headers: { ...corsHeaders },
      status: 204, // 204 No Content
    })

  } catch (error) {
    // --- ROLLBACK ON ERROR ---
    console.error("Error during work submission, starting rollback...", error)

    // NEW: Rollback the main file if it was uploaded
    if (uploadedFilePath) {
      await supabaseClient.storage.from('works-files').remove([uploadedFilePath]);
    }
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