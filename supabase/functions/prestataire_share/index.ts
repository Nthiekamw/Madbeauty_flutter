import { corsHeaders } from "../_shared/cors.ts";

const APP_SCHEME = "com.madbeauty.madbeauty";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const prestataireId = url.searchParams.get("prestataire_id")?.trim() ?? "";

  if (!prestataireId) {
    return new Response("Paramètre prestataire_id manquant.", {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "text/plain; charset=utf-8" },
    });
  }

  const deepLink = `${APP_SCHEME}://prestataire/${prestataireId}`;

  const html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="0;url=${deepLink}">
  <title>MadBeauty</title>
  <style>
    body { font-family: system-ui, sans-serif; padding: 2rem; text-align: center; }
    a { color: #7c3aed; }
  </style>
</head>
<body>
  <p>Ouverture de la fiche prestataire dans MadBeauty…</p>
  <p><a href="${deepLink}">Ouvrir l’application</a></p>
  <script>window.location.replace(${JSON.stringify(deepLink)});</script>
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
