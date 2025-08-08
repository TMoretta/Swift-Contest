import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { corsHeaders } from "../_shared/cors.ts";

serve(async (req) => {
  // Gestisce la richiesta pre-flight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Recupera la API key di Google Places
    const apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY");
    if (!apiKey) {
      throw new Error("Google Places API key not found in environment variables.");
    }

    // 2. Estrae l'ID del luogo dai parametri dell'URL
    const url = new URL(req.url);
    const placeId = url.searchParams.get("id");
    if (!placeId) {
      return new Response(JSON.stringify({ error: "Place ID is missing" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      });
    }

    // 3. Prepara e invia la richiesta all'API di Google Places
    const googleApiUrl = `https://places.googleapis.com/v1/places/${placeId}`;
    const headers = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": apiKey,
      // Manteniamo la FieldMask per ottimizzare la richiesta
      "X-Goog-FieldMask": "id,location,formattedAddress,shortFormattedAddress",
    };

    const googleResponse = await fetch(googleApiUrl, {
      method: "GET",
      headers,
    });

    // 4. Controlla la risposta di Google e la inoltra al client
    if (!googleResponse.ok) {
      const errorText = await googleResponse.text();
      return new Response(errorText, {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: googleResponse.status,
      });
    }

    const data = await googleResponse.json();

    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});