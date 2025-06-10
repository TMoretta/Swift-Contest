import { serve } from "https://deno.land/std@0.140.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const RESEND_API_URL = "https://api.resend.com/email";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

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
    const { email, member_role, token } = p_invitation;

    if (!email || !member_role || !token) {
      return new Response("Missing required invitation fields", {
        status: 400,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      });
    }

    // Chiamata alla RPC create_invitation
    const { data, error } = await supabase.rpc("create_invitation", { p_invitation });

    if (error) {
      console.error("DB Error:", error);
      return new Response(`Database error: ${error.message}`, {
        status: 500,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      });
    }

    // Invio email
    const subject =
      member_role === "juror"
        ? "You have been invited to vote in a contest"
        : "You have been invited to participate in a contest";

    const html = `
      <h1>Welcome!</h1>
      <p>You’ve been invited as a <strong>${member_role}</strong>.</p>
      <p>Use this token to join: <code>${token}</code></p>
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
      return new Response(`Error sending email: ${errorText}`, {
        status: emailRes.status,
        headers: {
          "Access-Control-Allow-Origin": "*",
        },
      });
    }

    return new Response("Invitation created and email sent!", {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    });
  } catch (error) {
    console.error("Server Error:", error);
    return new Response("Internal Server Error: " + error, {
      status: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
});
