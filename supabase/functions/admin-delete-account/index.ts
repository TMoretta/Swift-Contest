import "jsr:@supabase/functions-js/edge-runtime.d.ts"
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
    // This is the recommended pattern for server-to-server communication (e.g., Retool to Supabase).
    const apiKey = req.headers.get('X-API-Key');
    const secretKey = Deno.env.get('RETOOL_API_KEY');

    // 1. Check if the secret key is set in Supabase secrets.
    if (!secretKey) {
      throw new Error("RETOOL_API_KEY is not set in Supabase secrets.");
    }
    // 2. Check if the provided API key matches the secret.
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

    // Create a Supabase client with admin privileges (service_role)
    // This is necessary to perform admin-level operations.
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // --- PRE-DELETION CHECKS ---
    // Get the full user object to ensure they exist and to get their email for notification.
    const { data: { user: userToDelete }, error: getUserError } = await supabaseAdmin.auth.admin.getUserById(userIdToDelete);

    if (getUserError) {
      // If the user doesn't exist, we can't delete them.
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
    // This must happen BEFORE deleting the user, as cascade deletes will remove the data needed for notifications.

    // 1. Get user's full name for messages
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('full_name')
      .eq('id', userId)
      .single();
    const userFullName = profile?.full_name || 'A user';

    // 2. Handle notifications if the user is an ORGANIZER
    const { data: organizedContests } = await supabaseAdmin
      .from('contests')
      .select('id, name')
      .eq('organizer_id', userId);

    if (organizedContests && organizedContests.length > 0) {
      for (const contest of organizedContests) {
        // Notify all participants of this contest
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

        // Notify all jurors of this contest
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
      }
    }

    // 3. Handle notifications for contests the user PARTICIPATED in
    const { data: participations } = await supabaseAdmin
      .from('participations')
      .select('contest:contests(organizer_id, name)')
      .eq('participant_id', userId);

    if (participations && participations.length > 0) {
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

    // --- EMAIL NOTIFICATION ---
    // Send an email to the user informing them of the deletion.
    // This requires an email service provider like Resend and an API key stored as a Supabase secret.
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (resendApiKey && userEmail) {
      const resend = new Resend(resendApiKey);
      try {
        await resend.emails.send({
          from: 'Swift Contest <noreply@swiftcontest.com>',
          to: [userEmail],
          subject: 'Your Swift Contest Account Has Been Deleted',
          html: `
            <p>Hello ${userFullName || 'user'},</p>
            <p>This is a notification to inform you that your account on Swift Contest has been deleted by an administrator.</p>
            <p>If you believe this was a mistake, please contact our support team.</p>
            <p>Thank you,</p>
            <p>The Swift Contest Team</p>
          `,
        });
      } catch (emailError) {
        // Log the email error but don't block the user deletion process
        console.error("Failed to send deletion notification email:", emailError.message);
      }
    } else {
      console.warn("RESEND_API_KEY not set or user email not found. Skipping email notification.");
    }

    // --- FINAL DELETION ---
    // Finally, delete the user from auth. This will cascade to the 'profiles' table and all related data.
    // Deleting the user automatically invalidates all their sessions, so an explicit global sign-out is not necessary.
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(userId);

    if (deleteError) {
      throw deleteError;
    }

    return new Response(JSON.stringify({ message: `User ${userId} deleted successfully` }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    // Log the actual error to the server for debugging
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});