import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

// Interface for the request body, now simplified
interface RequestBody {
  contestId: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. --- API KEY AUTHORIZATION ---
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

    // 2. --- INPUT VALIDATION ---
    const { contestId }: RequestBody = await req.json();
    if (!contestId) {
      throw new Error("contestId is required in the request body.");
    }

    // 3. --- SETUP ADMIN CLIENT ---
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      { auth: { persistSession: false } }
    );

    // 4. --- PRE-DELETION FETCH ---
    // Fetch all related data needed for cleanup before deleting the main record.
    const { data: contestData, error: fetchError } = await supabaseAdmin
      .from('contests')
      .select(`
        name,
        images_paths,
        place_id,
        contest_rankings ( file_path ),
        juries ( voting_form_id ),
        participations ( works ( images_paths, file_path ) )
      `)
      .eq('id', contestId)
      .single();

    if (fetchError || !contestData) {
      return new Response(JSON.stringify({ error: "Contest not found." }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 404,
      });
    }

    // 5. --- NOTIFICATION LOGIC ---
    // (This section can be expanded to notify users about the deletion)

    // 6. --- STORAGE AND DANGLING RECORD CLEANUP ---

    // 6a. Contest-level files
    if (contestData.images_paths && contestData.images_paths.length > 0) {
      await supabaseAdmin.storage.from('contests-images').remove(contestData.images_paths);
    }
    const rankingPaths = contestData.contest_rankings.map(r => r.file_path);
    if (rankingPaths.length > 0) {
      await supabaseAdmin.storage.from('contests-rankings').remove(rankingPaths);
    }

    // 6b. Work-level files (images and zips)
    const allWorkPaths = contestData.participations.flatMap(p => p.works);
    const workImagePaths = allWorkPaths.flatMap(w => w.images_paths).filter(Boolean);
    const workFilePaths = allWorkPaths.map(w => w.file_path).filter(Boolean);

    if (workImagePaths.length > 0) {
      await supabaseAdmin.storage.from('works-images').remove(workImagePaths);
    }
    if (workFilePaths.length > 0) {
      await supabaseAdmin.storage.from('works-files').remove(workFilePaths);
    }

    // 6c. Dangling database records
    if (contestData.place_id) {
      await supabaseAdmin.from('places').delete().eq('id', contestData.place_id);
    }
    const votingFormIds = contestData.juries.map(j => j.voting_form_id);
    if (votingFormIds.length > 0) {
      await supabaseAdmin.from('voting_forms').delete().in('id', votingFormIds);
    }

    // 7. --- FINAL DELETION ---
    // Now, delete the main contest record. ON DELETE CASCADE will handle the rest.
    const { error: deleteError } = await supabaseAdmin
      .from('contests')
      .delete()
      .eq('id', contestId);

    if (deleteError) {
      throw deleteError;
    }

    // 8. --- SUCCESS RESPONSE ---
    return new Response(JSON.stringify({ message: `Contest "${contestData.name}" and all associated data have been deleted.` }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });

  } catch (error) {
    console.error("Admin-delete-contest error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});