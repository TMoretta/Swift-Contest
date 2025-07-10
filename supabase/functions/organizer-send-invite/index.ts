import { serve } from "https://deno.land/std@0.140.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const RESEND_API_URL = "https://api.resend.com/email";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization",
      },
    });
  }

  try {
    const { p_invitation } = await req.json();
    const { email, member_role, contest_id } = p_invitation;

    if (!email || !member_role || !contest_id) {
      return new Response("Missing required invitation fields", {
        status: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }

    // 1) Genera un token di 14 caratteri via RPC
    const {
      data: token,
      error: tokenError
    } = await supabase
      .rpc("gen_unique_token", {
        p_table: "invitations",
        p_column: "token",
        p_length: 14,
      });

    if (tokenError) {
      console.error("Token RPC Error:", tokenError);
      return new Response(`Error generating token: ${tokenError.message}`, {
        status: 500,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }
    if (typeof token !== "string") {
      console.error("Invalid token returned:", token);
      return new Response("Error: invalid token format", {
        status: 500,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }

    // 2) Inserisci l’invitation con quel token
    const { error: insertError } = await supabase
      .from("invitations")
      .insert(
        [
          {
            contest_id,
            email,
            member_role,
            token,
          },
        ],
        { returning: "minimal" }
      );

    if (insertError) {
      console.error("DB Insert Error:", insertError);
      return new Response(`Database insert error: ${insertError.message}`, {
        status: 500,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }

    // 3) Componi e invia l’email con Resend
    const subject =
      member_role === "juror"
        ? "You have been invited to vote in a contest"
        : "You have been invited to participate in a contest";

    const html = `
      <h2>Welcome!</h2>
      <p>You’ve been invited as a <strong>${member_role}</strong>.</p>
      <p>Use this token to join: <strong>${token}</strong></p>
    `;

    const emailRes = await fetch(RESEND_API_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Resend <onboarding@resend.dev>",
        to: [email],
        subject,
        html,
      }),
    });

    if (!emailRes.ok) {
      const errorText = await emailRes.text();
      console.error("Resend Error:", errorText);
      return new Response(`Error sending email: ${errorText}`, {
        status: emailRes.status,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }

    return new Response("Invitation created and email sent!", {
      status: 200,
      headers: { "Access-Control-Allow-Origin": "*" },
    });
  } catch (err) {
    console.error("Server Error:", err);
    return new Response("Internal Server Error", {
      status: 500,
      headers: { "Access-Control-Allow-Origin": "*" },
    });
  }
});
