import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

// Main Deno function
Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Create a Supabase client with admin privileges (service_role)
    // This is necessary to perform admin-level operations.
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // Get the user from the authorization header using the modern, secure pattern.
    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.");
    }
    const userId = user.id;

    // --- NOTIFICATION LOGIC ---
    // This must happen BEFORE deleting the user, as cascade deletes will remove the data needed for notifications.

    // 1. Get user's full name for messages
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('full_name')
      .eq('id', userId)
      .single();
    const userFullName = profile?.full_name || 'A user';

    // 2. Handle notifications and cleanup if the user is an ORGANIZER
    const { data: organizedContestsData } = await supabaseAdmin
      .from('contests')
      .select('id, name, images_paths, place_id, contest_rankings(file_path), juries(voting_form_id)')
      .eq('organizer_id', userId);

    if (organizedContestsData && organizedContestsData.length > 0) {
      for (const contest of organizedContestsData) {
        // Notify participants and jurors
        const { data: participants } = await supabaseAdmin
          .from('participations')
          .select('participant_id')
          .eq('contest_id', contest.id);

        if (participants && participants.length > 0) {
          const participantMessages = participants.map(p => ({
            account_id: p.participant_id,
            title: 'Contest Cancelled',
            body: `The contest "${contest.name}" has been cancelled because the organizer's account was deleted.`
          }));
          await supabaseAdmin.from('messages').insert(participantMessages);
        }

        const { data: jurors } = await supabaseAdmin
          .from('jurations')
          .select('juror_id')
          .eq('contest_id', contest.id);

        if (jurors && jurors.length > 0) {
          const jurorMessages = jurors.map(j => ({
            account_id: j.juror_id,
            title: 'Contest Cancelled',
            body: `The contest "${contest.name}" for which you were a juror has been cancelled because the organizer's account was deleted.`
          }));
          await supabaseAdmin.from('messages').insert(jurorMessages);
        }

        // --- STORAGE & RECORD CLEANUP for ORGANIZED CONTESTS ---
        // Delete contest images
        if (contest.images_paths && contest.images_paths.length > 0) {
          await supabaseAdmin.storage.from('contests-images').remove(contest.images_paths);
        }
        // Delete ranking files
        const rankingPaths = contest.contest_rankings.map(r => r.file_path);
        if (rankingPaths.length > 0) {
          await supabaseAdmin.storage.from('contests-rankings').remove(rankingPaths);
        }
        // Delete associated place
        if (contest.place_id) {
          await supabaseAdmin.from('places').delete().eq('id', contest.place_id);
        }
        // Delete associated voting forms
        const votingFormIds = contest.juries.map(j => j.voting_form_id);
        if (votingFormIds.length > 0) {
          await supabaseAdmin.from('voting_forms').delete().in('id', votingFormIds);
        }
      }
    }

    // 3. Handle notifications for contests the user PARTICIPATED in
    const { data: participations } = await supabaseAdmin
      .from('participations')
      .select('contest:contests(organizer_id, name), work:works(images_paths)')
      .eq('participant_id', userId);

    if (participations && participations.length > 0) {
      // --- STORAGE CLEANUP for PARTICIPATED CONTESTS ---
      const workImagePaths = participations
        .map(p => p.work?.images_paths)
        .flat()
        .filter(path => path) as string[];

      if (workImagePaths.length > 0) {
        await supabaseAdmin.storage.from('works-images').remove(workImagePaths);
      }

      const participationMessages = participations
        .filter(p => p.contest) // Ensure contest data was fetched
        .map(p => ({
          account_id: p.contest!.organizer_id,
          title: 'Participant Left Contest',
          body: `The participant "${userFullName}" has left your contest "${p.contest!.name}" because their account was deleted.`
        }));
      if (participationMessages.length > 0) {
        await supabaseAdmin.from('messages').insert(participationMessages);
      }
    }

    // 4. Handle notifications for contests the user was a JUROR in
    const { data: jurations } = await supabaseAdmin
      .from('jurations')
      .select('contest:contests(organizer_id, name)')
      .eq('juror_id', userId);

    if (jurations && jurations.length > 0) {
      const jurationMessages = jurations
        .filter(j => j.contest) // Ensure contest data was fetched
        .map(j => ({
          account_id: j.contest!.organizer_id,
          title: 'Juror Left Contest',
          body: `The juror "${userFullName}" has left your contest "${j.contest!.name}" because their account was deleted.`
        }));
      if (jurationMessages.length > 0) {
        await supabaseAdmin.from('messages').insert(jurationMessages);
      }
    }

    // 5. Finally, delete the user from auth. This will cascade to the 'profiles' table and all related data.
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(userId);

    if (deleteError) {
      throw deleteError;
    }

    return new Response(JSON.stringify({ message: "User deleted successfully" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    // Log the actual error to the server for debugging
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500, // Use 500 for general server-side errors
    });
  }
});