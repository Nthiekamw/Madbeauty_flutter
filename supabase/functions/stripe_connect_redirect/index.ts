import { corsHeaders } from "../_shared/cors.ts";

/** Deep links Android (voir AndroidManifest). */
const DEEP_LINKS: Record<string, string> = {
  return: "com.madbeauty.madbeauty://stripe-connect-return",
  refresh: "com.madbeauty.madbeauty://stripe-connect-refresh",
  subscription_success:
    "com.madbeauty.madbeauty://subscription-return?result=success",
  subscription_cancel:
    "com.madbeauty.madbeauty://subscription-return?result=cancel",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const to = url.searchParams.get("to") ?? "return";
  const deepLink = DEEP_LINKS[to] ?? DEEP_LINKS.return;

  const html = `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="0;url=${deepLink}">
  <title>Retour MadBeauty</title>
  <style>
    body { font-family: system-ui, sans-serif; padding: 2rem; text-align: center; }
    a { color: #7c3aed; }
  </style>
</head>
<body>
  <p>Redirection vers l’application MadBeauty…</p>
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
