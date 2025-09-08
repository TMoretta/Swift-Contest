import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { corsHeaders } from "../_shared/cors.ts";

// This function acts as a secure proxy to download the latest APK from a private GitHub repo.
Deno.serve(async (_req) => {
  // Handle CORS preflight requests
  if (_req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const GITHUB_PAT = Deno.env.get("GITHUB_PAT");
    if (!GITHUB_PAT) {
      throw new Error("GITHUB_PAT is not set in Supabase secrets.");
    }

    const GITHUB_REPO = "TMoretta/Swift-Contest"; // username/repo
    const GITHUB_API_URL = `https://api.github.com/repos/${GITHUB_REPO}/releases/latest`;

    // 1. Fetch the latest release data from GitHub using the Personal Access Token
    const releaseResponse = await fetch(GITHUB_API_URL, {
      headers: {
        Authorization: `Bearer ${GITHUB_PAT}`,
        Accept: "application/vnd.github.v3+json",
      },
    });

    if (!releaseResponse.ok) {
      if (releaseResponse.status === 404) {
        throw new Error("No releases found for this repository on GitHub.");
      }
      throw new Error(`GitHub API error: ${releaseResponse.statusText}`);
    }

    const releaseData = await releaseResponse.json();
    const assets = releaseData.assets || [];

    // 2. Find the APK asset in the release
    const apkAsset = assets.find((asset: { name: string }) => asset.name.endsWith(".apk"));

    if (!apkAsset || !apkAsset.url) {
      throw new Error("Could not find an APK file in the latest GitHub release.");
    }

    // 3. Fetch the actual APK file bytes using the asset's API URL
    const assetResponse = await fetch(apkAsset.url, {
      headers: {
        Authorization: `Bearer ${GITHUB_PAT}`,
        Accept: "application/octet-stream", // Request the raw file bytes
      },
    });

    if (!assetResponse.ok) {
      throw new Error(`Failed to download APK file: ${assetResponse.statusText}`);
    }

    // 4. Stream the file bytes back to the client
    return new Response(assetResponse.body, {
      headers: { ...corsHeaders, "Content-Type": "application/octet-stream" },
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