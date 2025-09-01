import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

interface RequestBody {
  contestId: string;
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

    // 2. Get contestId from request body
    const { contestId }: RequestBody = await req.json();
    if (!contestId) {
      throw new Error("contestId is required.");
    }

    // 3. Fetch all necessary data for the user's participation in this contest
    const { data: participationData, error: fetchError } = await supabaseAdmin
      .from('participations')
      .select(`
        id,
        participant:profiles!participant_id ( full_name ),
        contest:contests ( organizer_id, name ),
        work:works ( images_paths )
      `)
      .eq('contest_id', contestId)
      .eq('participant_id', user.id)
      .single();

    if (fetchError || !participationData) {
      throw new Error("Participation not found for this user in the specified contest.");
    }

    // 4. Send notification to the contest organizer
    await supabaseAdmin.from('messages').insert({
      account_id: participationData.contest!.organizer_id,
      title: 'Participant Left Contest',
      body: `The participant "${participationData.participant!.full_name}" has left your contest "${participationData.contest!.name}".`
    });

    // 5. Delete associated work images from storage, if they exist
    const workImages = participationData.work?.images_paths;
    if (workImages && workImages.length > 0) {
      const { error: storageError } = await supabaseAdmin.storage
        .from('works-images')
        .remove(workImages);

      if (storageError) {
        console.error(`Storage deletion error for participation ${participationData.id}:`, storageError.message);
      }
    }

    // 6. Delete the participation record.
    // The `on_work_delete` trigger is no longer needed for storage, but ON DELETE CASCADE on `works` table is still active.
    const { error: deleteError } = await supabaseAdmin
      .from('participations')
      .delete()
      .eq('id', participationData.id);

    if (deleteError) throw deleteError;

    return new Response(JSON.stringify({ message: "Successfully left the contest." }), {
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