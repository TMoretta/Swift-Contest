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

    // 3. Fetch contest and verify ownership
    const { data: contest, error: fetchError } = await supabaseAdmin
      .from('contests')
      .select('organizer_id, name, images_paths, place_id')
      .eq('id', contestId)
      .single();

    if (fetchError || !contest) {
      throw new Error("Contest not found.");
    }

    if (contest.organizer_id !== user.id) {
      return new Response(JSON.stringify({ error: "Access denied." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 403,
      });
    }

    // 4. Send notifications (must be done before data is deleted)
    // Notify participants
    const { data: participants } = await supabaseAdmin
      .from('participations')
      .select('participant_id')
      .eq('contest_id', contestId);

    if (participants && participants.length > 0) {
      const participantMessages = participants.map(p => ({
        account_id: p.participant_id,
        title: 'Contest Cancelled',
        body: `The contest "${contest.name}" you were participating in has been cancelled by the organizer.`
      }));
      await supabaseAdmin.from('messages').insert(participantMessages);
    }

    // Notify jurors (using Set to avoid duplicate messages for jurors in multiple juries)
    const { data: jurors } = await supabaseAdmin
      .from('jurations')
      .select('juror_id')
      .eq('contest_id', contestId);

    if (jurors && jurors.length > 0) {
      const jurorMessages = [...new Set(jurors.map(j => j.juror_id))].map(jurorId => ({
        account_id: jurorId,
        title: 'Contest Cancelled',
        body: `The contest "${contest.name}" for which you were a juror has been cancelled by the organizer.`
      }));
      await supabaseAdmin.from('messages').insert(jurorMessages);
    }

    // 5. Delete associated images from storage
    if (contest.images_paths && contest.images_paths.length > 0) {
      const { error: storageError } = await supabaseAdmin.storage
        .from('contests-images')
        .remove(contest.images_paths);

      if (storageError) {
        // Log the error but proceed with DB deletion to not block the user.
        console.error("Storage deletion error:", storageError.message);
      }
    }

    // 6. Delete the contest record from the database.
    // The `on_contest_delete` trigger will handle deleting the associated `place`.
    // Other related data will be deleted via `ON DELETE CASCADE`.
    const { error: deleteError } = await supabaseAdmin
      .from('contests')
      .delete()
      .eq('id', contestId);

    if (deleteError) throw deleteError;

    // 7. Delete the associated place record.
    // This is now handled here instead of a trigger for better control and error handling.
    if (contest.place_id) {
      const { error: placeDeleteError } = await supabaseAdmin
        .from('places')
        .delete()
        .eq('id', contest.place_id);

      if (placeDeleteError) {
        // Log the error but don't fail the whole function,
        // as the main contest deletion was successful.
        console.error("Place deletion error:", placeDeleteError.message);
      }
    }

    return new Response(JSON.stringify({ message: "Contest deleted successfully" }), {
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