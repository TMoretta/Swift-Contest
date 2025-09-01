import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

interface RequestBody {
  participationId: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Create admin and user-context clients
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    const { data: { user } } = await createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser();

    if (!user) {
      throw new Error("User not authenticated.");
    }

    // 2. Get participationId from request body
    const { participationId }: RequestBody = await req.json();
    if (!participationId) {
      throw new Error("participationId is required.");
    }

    // 3. Fetch all necessary data and verify ownership in one query
    const { data: participationData, error: fetchError } = await supabaseAdmin
      .from('participations')
      .select(`
        participant_id,
        contest:contests ( organizer_id, name ),
        work:works ( images_paths )
      `)
      .eq('id', participationId)
      .single();

    if (fetchError || !participationData) {
      throw new Error("Participation not found.");
    }

    if (participationData.contest?.organizer_id !== user.id) {
      return new Response(JSON.stringify({ error: "Access denied." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 403,
      });
    }

    // 4. Send notification to the participant being removed
    await supabaseAdmin.from('messages').insert({
      account_id: participationData.participant_id,
      title: 'Removed from Contest',
      body: `You have been removed from the contest "${participationData.contest?.name}".`
    });

    // 5. Delete associated work images from storage, if they exist
    const workImages = participationData.work?.images_paths;
    if (workImages && workImages.length > 0) {
      const { error: storageError } = await supabaseAdmin.storage
        .from('works-images')
        .remove(workImages);

      if (storageError) {
        // Log the error but proceed with DB deletion to not block the user.
        console.error(`Storage deletion error for participation ${participationId}:`, storageError.message);
      }
    }

    // 6. Delete the participation record.
    // ON DELETE CASCADE will handle deleting the associated work record.
    const { error: deleteError } = await supabaseAdmin
      .from('participations')
      .delete()
      .eq('id', participationId);

    if (deleteError) {
      throw deleteError;
    }

    return new Response(JSON.stringify({ message: "Participant removed successfully" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});