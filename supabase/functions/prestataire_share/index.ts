import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { corsHeaders } from "../_shared/cors.ts";

const APP_SCHEME = "com.madbeauty.madbeauty";
const DEFAULT_WEB_SHARE_BASE = "https://madbeauty.pro";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const prestataireId = url.searchParams.get("prestataire_id")?.trim() ?? "";
  const slugParam = url.searchParams.get("slug")?.trim() ?? "";

  if (!prestataireId && !slugParam) {
    return new Response("Paramètre prestataire_id ou slug manquant.", {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "text/plain; charset=utf-8" },
    });
  }

  const webBase = (Deno.env.get("SHARE_WEB_BASE_URL")?.trim() ||
    DEFAULT_WEB_SHARE_BASE).replace(/\/+$/, "");

  let slug = slugParam.replace(/^@/, "").toLowerCase();
  let resolvedId = prestataireId;

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const supabaseAnon = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
  if (supabaseUrl && supabaseAnon) {
    try {
      const supabase = createClient(supabaseUrl, supabaseAnon);
      if (prestataireId) {
        const { data } = await supabase
          .from("prestataire_profiles")
          .select("id, public_slug")
          .eq("id", prestataireId)
          .maybeSingle();
        if (data?.public_slug) slug = String(data.public_slug);
        if (data?.id) resolvedId = String(data.id);
      } else if (slug) {
        const { data } = await supabase.rpc("resolve_prestataire_public_ref", {
          p_ref: slug,
        });
        if (typeof data === "string" && data.length > 0) {
          resolvedId = data;
        }
      }
    } catch (_) {
      // Soft : on garde le fallback UUID / slug fourni.
    }
  }

  const webUrl = slug
    ? `${webBase}/@${slug}`
    : `${webBase}/prestataire/${resolvedId}`;
  const deepLink = slug
    ? `${APP_SCHEME}://@${slug}`
    : `${APP_SCHEME}://prestataire/${resolvedId}`;

  const html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="0;url=${webUrl}">
  <title>MadBeauty</title>
  <style>
    body { font-family: system-ui, sans-serif; padding: 2rem; text-align: center; }
    a { color: #7c3aed; display: inline-block; margin: 0.5rem; }
  </style>
</head>
<body>
  <p>Redirection vers la fiche prestataire…</p>
  <p><a href="${webUrl}">Voir la fiche dans le navigateur</a></p>
  <p><a href="${deepLink}">Ouvrir dans l’application MadBeauty</a></p>
  <script>window.location.replace(${JSON.stringify(webUrl)});</script>
</body>
</html>`;

  return new Response(html, {
    status: 200,
    headers: {
      ...corsHeaders,
      "Content-Type": "text/html; charset=utf-8",
    },
  });
});
