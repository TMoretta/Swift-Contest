import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Resend } from "https://esm.sh/resend@3.2.0";
import { corsHeaders } from "../_shared/cors.ts";

// Define a type for the expected request body
interface RequestBody {
  userIdToDelete: string;
}

// Main Deno function
Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // --- API KEY AUTHORIZATION ---
    const apiKey = req.headers.get('X-API-Key');
    const secretKey = Deno.env.get('RETOOL_API_KEY');

    if (!secretKey) {
      throw new Error("RETOOL_API_KEY is not set in Supabase secrets.");
    }
    if (apiKey !== secretKey) {
      return new Response(JSON.stringify({ error: "Unauthorized. Invalid API Key." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 401,
      });
    }

    // --- INPUT VALIDATION ---
    const { userIdToDelete }: RequestBody = await req.json();

    if (!userIdToDelete) {
      throw new Error("userIdToDelete is required in the request body.");
    }

    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // --- PRE-DELETION CHECKS ---
    const { data: { user: userToDelete }, error: getUserError } = await supabaseAdmin.auth.admin.getUserById(userIdToDelete);

    if (getUserError) {
      if (getUserError.message.includes("User not found")) {
        return new Response(JSON.stringify({ error: "User not found." }), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 404,
        });
      }
      throw getUserError;
    }

    const userEmail = userToDelete.email;
    const userId = userIdToDelete;

    // --- NOTIFICATION LOGIC ---
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('full_name')
      .eq('id', userId)
      .single();
    const userFullName = profile?.full_name || 'A user';

    // 1. Handle notifications for ORGANIZED contests
    const { data: organizedContestsData } = await supabaseAdmin
      .from('contests')
      .select('id, name, images_paths, place_id, contest_rankings(file_path), juries(voting_form_id)')
      .eq('organizer_id', userId);

    if (organizedContestsData && organizedContestsData.length > 0) {
      for (const contest of organizedContestsData) {
        // Notify participants and jurors
        const { data: participants } = await supabaseAdmin.from('participations').select('participant_id').eq('contest_id', contest.id);
        if (participants && participants.length > 0) {
          const participantMessages = participants.map(p => ({
            account_id: p.participant_id,
            title: 'Contest Cancelled',
            body: `The contest "${contest.name}" has been cancelled because the organizer's account was deleted.`
          }));
          await supabaseAdmin.from('messages').insert(participantMessages);
        }

        const { data: jurors } = await supabaseAdmin.from('jurations').select('juror_id').eq('contest_id', contest.id);
        if (jurors && jurors.length > 0) {
          const jurorMessages = jurors.map(j => ({
            account_id: j.juror_id,
            title: 'Contest Cancelled',
            body: `The contest "${contest.name}" for which you were a juror has been cancelled because the organizer's account was deleted.`
          }));
          await supabaseAdmin.from('messages').insert(jurorMessages);
        }

        // --- STORAGE & RECORD CLEANUP for ORGANIZED CONTESTS ---
        if (contest.images_paths && contest.images_paths.length > 0) {
          await supabaseAdmin.storage.from('contests-images').remove(contest.images_paths);
        }
        const rankingPaths = contest.contest_rankings.map(r => r.file_path);
        if (rankingPaths.length > 0) {
          await supabaseAdmin.storage.from('contests-rankings').remove(rankingPaths);
        }
        if (contest.place_id) {
          await supabaseAdmin.from('places').delete().eq('id', contest.place_id);
        }
        const votingFormIds = contest.juries.map(j => j.voting_form_id);
        if (votingFormIds.length > 0) {
          await supabaseAdmin.from('voting_forms').delete().in('id', votingFormIds);
        }
      }
    }

    // 2. Handle notifications and cleanup for PARTICIPATED contests
    const { data: participations } = await supabaseAdmin
      .from('participations')
      // UPDATED: Select 'file_path' from the related work as well
      .select('contest:contests(organizer_id, name), work:works(images_paths, file_path)')
      .eq('participant_id', userId);

    if (participations && participations.length > 0) {
      // --- STORAGE CLEANUP for PARTICIPATED CONTESTS ---
      // Cleanup work images
      const workImagePaths = participations
        .map(p => p.work?.images_paths)
        .flat()
        .filter(path => path) as string[];

      if (workImagePaths.length > 0) {
        await supabaseAdmin.storage.from('works-images').remove(workImagePaths);
      }

      // NEW: Cleanup work files (ZIPs)
      const workFilePaths = participations
        .map(p => p.work?.file_path)
        .filter(path => path) as string[]; // .flat() is not needed as it's a single path

      if (workFilePaths.length > 0) {
        await supabaseAdmin.storage.from('works-files').remove(workFilePaths);
      }

      // Notify organizers
      const participationMessages = participations
        .filter(p => p.contest)
        .map(p => ({
          account_id: p.contest!.organizer_id,
          title: 'Participant Left Contest',
          body: `The participant "${userFullName}" has left your contest "${p.contest!.name}" because their account was deleted.`
        }));
      if (participationMessages.length > 0) {
        await supabaseAdmin.from('messages').insert(participationMessages);
      }
    }

    // 3. Handle notifications for JUROR contests
    const { data: jurations } = await supabaseAdmin
      .from('jurations')
      .select('contest:contests(organizer_id, name)')
      .eq('juror_id', userId);

    if (jurations && jurations.length > 0) {
      const jurationMessages = jurations
        .filter(j => j.contest)
        .map(j => ({
          account_id: j.contest!.organizer_id,
          title: 'Juror Left Contest',
          body: `The juror "${userFullName}" has left your contest "${j.contest!.name}" because their account was deleted.`
        }));
      if (jurationMessages.length > 0) {
        await supabaseAdmin.from('messages').insert(jurationMessages);
      }
    }

    // --- EMAIL NOTIFICATION ---
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (resendApiKey && userEmail) {
      const resend = new Resend(resendApiKey);
      try {
        await resend.emails.send({
          from: 'Swift Contest <noreply@swiftcontest.com>',
          to: [userEmail],
          subject: 'Your Swift Contest Account Has Been Deleted',
          html: `<p>Hello ${userFullName || 'user'},</p><p>This is a notification to inform you that your account on Swift Contest has been deleted by an administrator.</p><p>If you believe this was a mistake, please contact our support team.</p><p>Thank you,</p><p>The Swift Contest Team</p>`,
        });
      } catch (emailError) {
        console.error("Failed to send deletion notification email:", emailError.message);
      }
    } else {
      console.warn("RESEND_API_KEY not set or user email not found. Skipping email notification.");
    }

    // --- FINAL DELETION ---
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(userId);

    if (deleteError) {
      throw deleteError;
    }

    return new Response(JSON.stringify({ message: `User ${userId} deleted successfully` }), {
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