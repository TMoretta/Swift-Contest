// C:/Users/Tommaso/Desktop/Swift-Contest/supabase/functions/invite-participant/index.ts

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Resend } from 'npm:resend';
import { corsHeaders } from "../_shared/cors.ts";

// Initialize Resend with your API key from secrets
const resend = new Resend(Deno.env.get('RESEND_API_KEY'));

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Create a Supabase client with admin privileges
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // 2. Get the user from the authorization header.
    const { data: { user } } = await createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? '',
        { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    ).auth.getUser()

    if (!user) {
      throw new Error("User not authenticated.")
    }

     // 3. Extract data from the request body
     const { participant_invitation } = await req.json();
     if (!participant_invitation) {
       throw new Error("Missing 'participant_invitation' in request body.");
     }
     const { contest_id, email } = participant_invitation;
     if (!contest_id || !email) { // Check inside the nested object
       throw new Error("Missing required fields: contest_id, email");
     }

    // 4. SECURITY: Verify that the user is the organizer of the contest
    //    and retrieve the contest name for the email.
    const { data: contest, error: contestError } = await supabaseAdmin
      .from('contests')
      .select('name, organizer_id')
      .eq('id', contest_id)
      .single();

    if (contestError || !contest) {
      throw new Error("Contest not found.");
    }
    if (contest.organizer_id !== user.id) {
      return new Response(JSON.stringify({ error: "Forbidden: You are not the organizer of this contest." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 403,
      });
    }

    // 5. Insert the new invitation and retrieve the complete row, including the token.
    const { data: newInvitation, error: insertError } = await supabaseAdmin
      .from('participant_invitations')
      .insert({ contest_id, email })
      .select()
      .single();

    if (insertError || !newInvitation) {
      throw new Error("Failed to create invitation record.");
    }

    await resend.emails.send({
      from: "Swift Contest <noreply@swiftcontest.com>",
      to: [email],
      subject: `You have been invited to participate in "${contest.name}"`,
      html: `
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
          <div style="max-width: 600px; margin: auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;">
            <h1 style="color: #007bff;">Invitation to Swift Contest</h1>
            <p>Hello!</p>
            <p>You have received an invitation to participate in the contest "<strong>${contest.name}</strong>".</p>
            <p style="margin-top: 20px; font-size: 12px; color: #666;">
              Use this token in the app:<br>
              <strong style="font-size: 14px; color: #333;">${newInvitation.token}</strong>
            </p>
          </div>
        </div>
      `,
    });


    // 7. Return the created invitation to the client.
    return new Response(JSON.stringify(newInvitation), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 201, // Created
    });

  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500, // Use 500 for general server-side errors
    });
  }
});