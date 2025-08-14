import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { corsHeaders } from "../_shared/cors.ts";

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Retrieve the Google Places API key from environment variables.
    const apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY");
    if (!apiKey) {
      throw new Error("Google Places API key not found in environment variables.");
    }

    // 2. Extract the place ID from the request body.
    const { place_id: placeId } = await req.json();
    if (!placeId) {
      return new Response(JSON.stringify({ error: "Place ID is missing" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      });
    }

    // 3. Prepare and send the request to the Google Places API.
    const googleApiUrl = `https://places.googleapis.com/v1/places/${placeId}`;
    const headers = {
      "Content-Type": "application/json",
      "X-Goog-Api-Key": apiKey,
      // Use a FieldMask to optimize the request and only get the data we need.
      "X-Goog-FieldMask": "id,location,formattedAddress,shortFormattedAddress",
    };

    const googleResponse = await fetch(googleApiUrl, {
      method: "GET",
      headers,
    });

    // 4. Check the response from Google and forward the error if it's not ok.
    if (!googleResponse.ok) {
      const errorText = await googleResponse.text();
      return new Response(errorText, {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: googleResponse.status,
      });
    }

    const googleData = await googleResponse.json();

    // 5. Transform the data to match the client's expected format (e.g., Place entity).
    // This simplifies the client-side parsing logic.
    const transformedData = {
      id: googleData.id,
      address: googleData.formattedAddress,
      lat: googleData.location.latitude,
      lon: googleData.location.longitude,
      // created_at is handled by the database, so we don't include it here.
    };

    return new Response(JSON.stringify(transformedData), {
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