import { corsHeaders } from "../_shared/cors.ts";

/** Deep links Android (voir AndroidManifest). */
const DEEP_LINKS: Record<string, string> = {
  return: "com.madbeauty.madbeauty://stripe-connect-return",
  refresh: "com.madbeauty.madbeauty://stripe-connect-refresh",
  subscription_success:
    "com.madbeauty.madbeauty://subscription-return?result=success",
  subscription_cancel:
    "com.madbeauty.madbeauty://subscription-return?result=cancel",
  client_payment_return:
    "com.madbeauty.madbeauty://client-payment-return",
};

const ANDROID_PACKAGE = "com.madbeauty.madbeauty";

function androidIntentUrl(deepLink: string): string {
  const withoutScheme = deepLink.replace(/^[^:]+:\/\//, "");
  return `intent://${withoutScheme}#Intent;scheme=com.madbeauty.madbeauty;package=${ANDROID_PACKAGE};end`;
}

/** Page de secours si la redirection 302 ne s ouvre pas dans l app. */
function htmlFallbackPage(deepLink: string): string {
  const intentUrl = androidIntentUrl(deepLink);
  return `<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta http-equiv="refresh" content="0;url=${deepLink}">
  <title>Retour MadBeauty</title>
  <style>
    body { font-family: system-ui, sans-serif; padding: 2rem; text-align: center; background: #faf7f3; color: #2d211c; }
    a { color: #4a3328; font-weight: 600; }
    .btn { display: inline-block; margin: 0.5rem; padding: 12px 20px; background: #4a3328; color: #fff; text-decoration: none; border-radius: 12px; }
  </style>
</head>
<body>
  <h1 style="font-size:1.25rem;">Retour vers MadBeauty</h1>
  <p>Si l application ne s ouvre pas automatiquement :</p>
  <p><a class="btn" href="${deepLink}">Ouvrir MadBeauty</a></p>
  <p><a href="${intentUrl}">Ouvrir sur Android</a></p>
  <script>
    (function () {
      var target = ${JSON.stringify(deepLink)};
      try { window.location.replace(target); } catch (e) {}
      setTimeout(function () { window.location.href = target; }, 250);
    })();
  </script>
</body>
</html>`;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  const to = url.searchParams.get("to") ?? "return";
  const deepLink = DEEP_LINKS[to] ?? DEEP_LINKS.return;

  // Par defaut : redirection HTTP vers le deep link (evite la page HTML affichee en texte brut).
  const useHtmlFallback = url.searchParams.get("fallback") === "1";

  if (!useHtmlFallback) {
    return new Response(null, {
      status: 302,
      headers: {
        ...corsHeaders,
        Location: deepLink,
        "Cache-Control": "no-store, no-cache, must-revalidate",
      },
    });
  }

  const html = htmlFallbackPage(deepLink);
  return new Response(html, {
    status: 200,
    headers: {
      ...corsHeaders,
      "Content-Type": "text/html; charset=UTF-8",
      "X-Content-Type-Options": "nosniff",
      "Cache-Control": "no-store",
    },
  });
});
