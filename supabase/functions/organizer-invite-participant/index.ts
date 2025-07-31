// C:/Users/Tommaso/Desktop/Swift-Contest/supabase/functions/invite-participant/index.ts

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { Resend } from 'npm:resend';
import { corsHeaders } from "../_shared/cors.ts";

// Inizializza Resend con la tua API key presa dai secrets
const resend = new Resend(Deno.env.get('RESEND_API_KEY'));

Deno.serve(async (req) => {
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

    // 2. Verifica l'autenticazione e i permessi dell'organizzatore
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      throw new Error("Missing Authorization header");
    }
    const { data: { user } } = await supabaseAdmin.auth.getUser(authHeader.replace("Bearer ", ""));
    if (!user) {
      throw new Error("User not found for the provided JWT");
    }

    // 3. Estrae i dati dal corpo della richiesta
    const { contest_id, email } = await req.json();
    if (!contest_id || !email) {
      throw new Error("Missing required fields: contest_id, email");
    }

    // 4. SICUREZZA: Verifica che l'utente sia l'organizzatore del contest
    //    e recupera il nome del contest per l'email.
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

    // 5. Inserisce il nuovo invito e recupera la riga completa, incluso il token
    const { data: newInvitation, error: insertError } = await supabaseAdmin
      .from('participant_invitations')
      .insert({ contest_id, email })
      .select()
      .single();

    if (insertError) {
      throw insertError;
    }

    // 6. Invia l'email di invito usando Resend
    const inviteUrl = `${Deno.env.get('SUPABASE_URL')}/auth/v1/verify?type=invite&token=${newInvitation.token}&redirect_to=/`;

    await resend.emails.send({
      from: "Swift Contest <onboarding@resend.dev>",
      to: [email],
      subject: `Sei stato invitato a partecipare a "${contest.name}"`,
      html: `
        <h1>Invito a Swift Contest</h1>
        <p>Ciao!</p>
        <p>Hai ricevuto un invito per partecipare al contest "<strong>${contest.name}</strong>".</p>
        <p>Usa il seguente token per accedere al contest: <strong>${newInvitation.token}</strong></p>
      `,
    });

    // 7. Restituisce l'invito creato al client
    return new Response(JSON.stringify(newInvitation), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 201, // Created
    });

  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});