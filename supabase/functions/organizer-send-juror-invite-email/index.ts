// C:/Users/Tommaso/Desktop/Swift-Contest/supabase/functions/send-juror-invite-email/index.ts

import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Estrae i dati specifici dell'invito dal corpo della richiesta (inviati dal trigger)
    const { email, token, contest_name, jury_name } = await req.json();

    // 2. Costruisce il contenuto dell'email
    const subject = `Invito a far parte della giuria per "${contest_name}"`;
    const inviteUrl = `${Deno.env.get('SUPABASE_URL')}/auth/v1/verify?type=invite&token=${token}&redirect_to=/`;

    const htmlBody = `
      <h1>Invito a Swift Contest</h1>
      <p>Ciao!</p>
      <p>Hai ricevuto un invito per far parte della giuria "<strong>${jury_name}</strong>" per il contest "<strong>${contest_name}</strong>".</p>
      <p>Clicca sul link sottostante per accettare e creare il tuo account:</p>
      <a href="${inviteUrl}" style="display: inline-block; padding: 12px 24px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px; font-size: 16px;">
        Accetta Invito
      </a>
      <p>Se non riesci a cliccare il bottone, copia e incolla questo link nel tuo browser:</p>
      <p>${inviteUrl}</p>
      <br>
      <p>Il team di Swift Contest</p>
    `;

    // 3. Chiama la funzione generica 'send-email' per effettuare l'invio
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    const { error: emailError } = await supabaseAdmin.functions.invoke('send-email', {
      body: {
        to: email,
        subject: subject,
        html: htmlBody
      }
    });

    if (emailError) {
      throw emailError;
    }

    return new Response(JSON.stringify({ message: "Invitation process initiated." }), {
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