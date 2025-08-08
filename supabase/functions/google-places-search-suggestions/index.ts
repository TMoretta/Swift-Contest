import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";

// Funzione principale che gestisce le richieste in entrata
serve(async (req) => {
  // Gestisce la richiesta pre-flight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Recupera la API key di Google Places dai segreti di Supabase
    const apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY");
    if (!apiKey) {
      throw new Error("Google Places API key not found in environment variables.");
    }

    // 2. Estrae la query di ricerca dal corpo della richiesta
    const { query } = await req.json();
    if (!query) {
      return new Response(JSON.stringify({ error: "Query parameter is missing" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      });
    }

    // 3. Prepara e invia la richiesta all'API di Google Places
    const googleApiUrl = "https://places.googleapis.com/v1/places:autocomplete";
    const headers = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": apiKey,
    };
    const body = JSON.stringify({ input: query });

    const googleResponse = await fetch(googleApiUrl, {
      method: "POST",
      headers,
      body,
    });

    // 4. Controlla la risposta di Google e la inoltra al client
    if (!googleResponse.ok) {
      const errorText = await googleResponse.text();
      // Inoltra lo stesso status code e messaggio di errore di Google
      return new Response(errorText, {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: googleResponse.status,
      });
    }

    const data = await googleResponse.json();

    // Inoltra la risposta di successo al client
    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    // Gestisce errori interni della Edge Function
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});