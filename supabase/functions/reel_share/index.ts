import { corsHeaders } from "../_shared/cors.ts";

const APP_SCHEME = "com.madbeauty.madbeauty";
const DEFAULT_WEB_SHARE_BASE = "https://madbeauty.pro";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const reelId = url.searchParams.get("reel_id")?.trim() ?? "";

  if (!reelId) {
    return new Response("Paramètre reel_id manquant.", {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "text/plain; charset=utf-8" },
    });
  }

  const webBase = (Deno.env.get("SHARE_WEB_BASE_URL")?.trim() ||
    DEFAULT_WEB_SHARE_BASE).replace(/\/+$/, "");
  const webUrl = `${webBase}/reel/${reelId}`;
  const deepLink = `${APP_SCHEME}://reel/${reelId}`;

  const html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="0;url=${deepLink}">
  <title>MadBeauty Reel</title>
  <style>
    body { font-family: system-ui, sans-serif; padding: 2rem; text-align: center; }
    a { color: #7c3aed; display: inline-block; margin: 0.5rem; }
  </style>
</head>
<body>
  <p>Ouverture du Reel MadBeauty…</p>
  <p><a href="${deepLink}">Ouvrir dans l’application</a></p>
  <p><a href="${webUrl}">Lien web</a></p>
  <script>
    window.location.replace(${JSON.stringify(deepLink)});
    setTimeout(function () {
      window.location.replace(${JSON.stringify(webUrl)});
    }, 800);
  </script>
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
