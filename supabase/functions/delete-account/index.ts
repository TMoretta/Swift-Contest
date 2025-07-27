// C:/Users/Tommaso/Desktop/Swift-Contest/supabase/functions/delete-account/index.ts

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts"; // È buona norma avere un file condiviso per gli header

// Funzione principale servita da Deno
Deno.serve(async (req) => {
  // Gestisce la richiesta preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Crea un client Supabase con i permessi di amministratore (service_role)
    // Questo è necessario per eseguire operazioni di tipo 'admin'
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } } // Best practice per il server-side
    );

    // Get the authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      throw new Error("Missing Authorization header");
    }

    // Get the user from the JWT
    const { data: { user } } = await supabaseAdmin.auth.getUser(
      authHeader.replace("Bearer ", "")
    );

    if (!user) {
      throw new Error("User not found for the provided JWT");
    }

    // Delete the user using the admin client
    const { error } = await supabaseAdmin.auth.admin.deleteUser(user.id);

    if (error) {
      // Inoltra l'errore specifico di Supabase
      throw error;
    }

    return new Response(JSON.stringify({ message: "User deleted successfully" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    // Logga l'errore effettivo sul server per il debug
    console.error(error); 
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});