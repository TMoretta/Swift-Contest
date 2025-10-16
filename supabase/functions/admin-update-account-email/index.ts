import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Security Check: Verify the admin API key from the request header.
    // This key must be stored as an environment variable in your Supabase project.
    const adminApiKey = Deno.env.get("RETOOL_API_KEY");
    const requestApiKey = req.headers.get("X-API-Key");

    if (!adminApiKey || requestApiKey !== adminApiKey) {
      throw new Error("Unauthorized: Invalid or missing API Key.");
    }

    // 2. Parse the request body to get the user ID and the new email.
    const { user_id, new_email } = await req.json();
    if (!user_id || !new_email) {
      throw new Error("Missing required parameters: user_id and new_email are required.");
    }

    // 3. Create a Supabase client with admin privileges using the service_role key.
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // 4. Use the admin client to update the user's email by their ID.
    const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
      user_id,
      { email: new_email }
    );

    if (error) {
      // Provide more specific feedback if the email is already in use.
      if (error.message.includes("unique constraint")) {
        throw new Error("This email address is already in use by another account.");
      }
      throw error; // Re-throw other errors.
    }

    // 5. Return a success response.
    return new Response(JSON.stringify({ message: "User email updated successfully.", user: data.user }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    // Handle any errors that occur during the process.
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});