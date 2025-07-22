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
    const { params } = await req.json();
    const { p_user_id, p_email} = params;

    if (!p_user_id || !p_email) {
      return new Response("Missing required parameters", {
        status: 400,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }

    const {
      data: success,
      error: error
    } = await supabase
      .rpc("admin_delete_user_by_id", {
        p_user_id: p_user_id,
      });

    if (error) {
      console.error("Error:", error);
      return new Response(`Error while deleting user: ${error.message}`, {
        status: 500,
        headers: { "Access-Control-Allow-Origin": "*" },
      });
    }

    // 3) Componi e invia l’email con Resend
    const subject = "Your account has been deleted by the admin"

    const html = `
      <p>Your account has been deleted by the admin.</p>
    `;

    const emailRes = await fetch(RESEND_API_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Resend <onboarding@resend.dev>",
        to: [p_email],
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

    return new Response("User deleted successfully", {
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
