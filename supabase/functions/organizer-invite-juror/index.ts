// C:/Users/Tommaso/Desktop/Swift-Contest/supabase/functions/organizer-invite-juror/index.ts

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  // Gestisce la richiesta preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Crea un client Supabase con permessi di amministratore
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // 2. Verifica l'autenticazione dell'utente che chiama la funzione
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      throw new Error("Missing Authorization header");
    }
    const { data: { user } } = await supabaseAdmin.auth.getUser(authHeader.replace("Bearer ", ""));
    if (!user) {
      throw new Error("User not found for the provided JWT");
    }

    // 3. Estrae i dati dell'invito dal corpo della richiesta
    const { contest_id, jury_id, email } = await req.json();
    if (!contest_id || !jury_id || !email) {
      throw new Error("Missing required fields: contest_id, jury_id, email");
    }

    // 4. SICUREZZA: Verifica che l'utente sia l'organizzatore del contest
    const { data: contest, error: contestError } = await supabaseAdmin
      .from('contests')
      .select('organizer_id')
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

    // 5. Inserisce il nuovo invito nel database. Il token viene generato dal DEFAULT.
    const { data: newInvitation, error: insertError } = await supabaseAdmin
      .from('juror_invitations')
      .insert({
        contest_id: contest_id,
        jury_id: jury_id,
        email: email,
      })
      .select()
      .single();

    if (insertError) {
      // Potrebbe essere un errore di email duplicata, ecc.
      throw insertError;
    }

    // L'invito è stato creato. Il trigger si occuperà dell'email.
    return new Response(JSON.stringify(newInvitation), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});