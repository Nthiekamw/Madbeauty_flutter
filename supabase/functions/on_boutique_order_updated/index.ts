import {
  createServiceClient,
  fetchFcmTokenForClientProfileId,
  sendFcmNotification,
  verifyWebhookSecret,
  type WebhookPayload,
} from "../_shared/booking_notify.ts";

function clientCopyForStatut(statut: string): { title: string; body: string } | null {
  switch (statut) {
    case "preparing":
      return {
        title: "MadBeauty",
        body: "Ta commande boutique est en préparation",
      };
    case "ready":
      return {
        title: "MadBeauty",
        body: "Ta commande boutique est prête",
      };
    case "completed":
      return {
        title: "MadBeauty",
        body: "Ta commande boutique est terminée",
      };
    case "canceled":
      return {
        title: "MadBeauty",
        body: "Ta commande boutique a été annulée",
      };
    default:
      return null;
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }
  try {
    if (!verifyWebhookSecret(req)) {
      return new Response("Unauthorized", { status: 401 });
    }

    const payload = await req.json() as WebhookPayload;
    if (payload.type !== "UPDATE" || !payload.record || !payload.old_record) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const record = payload.record;
    const old = payload.old_record;
    const newS = String(record["statut"] ?? "").trim();
    const oldS = String(old["statut"] ?? "").trim();
    if (newS === oldS) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const copy = clientCopyForStatut(newS);
    if (!copy) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const clientId = String(record["client_id"] ?? "");
    if (!clientId) {
      return new Response(
        JSON.stringify({ ok: false, error: "client_id manquant" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const supabase = createServiceClient();
    const token = await fetchFcmTokenForClientProfileId(supabase, clientId);
    if (!token) {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "no fcm_token" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    await sendFcmNotification({
      token,
      title: copy.title,
      body: copy.body,
      data: {
        type: "boutique_order_status",
        commande_id: String(record["id"] ?? ""),
        status: newS,
      },
    });

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ ok: false, error: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
