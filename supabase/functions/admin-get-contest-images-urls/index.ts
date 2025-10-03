import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

interface RequestBody {
  contestId: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. API KEY AUTHORIZATION (Security for server-to-server calls)
    const apiKey = req.headers.get('X-API-Key');
    const secretKey = Deno.env.get('RETOOL_API_KEY');

    if (!secretKey) {
      throw new Error("RETOOL_API_KEY is not set in Supabase secrets.");
    }
    if (apiKey !== secretKey) {
      return new Response(JSON.stringify({ error: "Unauthorized. Invalid API Key." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 401,
      });
    }

    // 2. Get contestId from request body
    const { contestId }: RequestBody = await req.json();
    if (!contestId) {
      throw new Error("contestId is required in the request body.");
    }

    // 3. Create an admin client to perform privileged operations
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // 4. Fetch the image paths for the specified contest
    const { data: contestData, error: fetchError } = await supabaseAdmin
      .from('contests')
      .select('images_paths')
      .eq('id', contestId)
      .single();

    if (fetchError || !contestData) {
      return new Response(JSON.stringify({ error: "Contest not found." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 404,
      });
    }

    const imagePaths = contestData.images_paths;

    // 5. Handle cases with no images
    if (!imagePaths || imagePaths.length === 0) {
      return new Response(JSON.stringify([]), { // Return an empty array
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    // 6. Generate signed URLs for the found paths
    const { data: signedUrlsData, error: signedUrlsError } = await supabaseAdmin.storage
      .from('contests-images')
      .createSignedUrls(imagePaths, 60); // URLs are valid for 60 seconds

    if (signedUrlsError) {
      throw signedUrlsError;
    }

    // 7. Return the signed URLs
    return new Response(JSON.stringify(signedUrlsData), {
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