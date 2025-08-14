import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { corsHeaders } from "../_shared/cors.ts";

// Main Deno function to handle incoming requests
Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Retrieve the Google Places API key from Supabase secrets
    const apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY");
    if (!apiKey) {
      throw new Error("Google Places API key not found in environment variables.");
    }

    // 2. Extract the search query from the request body
    const { query } = await req.json();
    if (!query) {
      return new Response(JSON.stringify({ error: "Query parameter is missing" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      });
    }

    // 3. Prepare and send the request to the Google Places Autocomplete API
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

    // 4. Check the response from Google and forward the error if it's not ok
    if (!googleResponse.ok) {
      const errorText = await googleResponse.text();
      // Forward the same status code and error message from Google
      return new Response(errorText, {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: googleResponse.status,
      });
    }

    const googleData = await googleResponse.json();

    // 5. Transform the complex Google response into a simple list for the client.
    const transformedSuggestions = (googleData.suggestions || []).map((suggestion: any) => {
      return {
        placeId: suggestion.placePrediction?.placeId,
        address: suggestion.placePrediction?.text?.text,
      };
    }).filter((s: any) => s.placeId && s.address); // Filter out any malformed suggestions

    // Return the simplified list to the client
    return new Response(JSON.stringify(transformedSuggestions), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    // Handle internal errors in the Edge Function
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});