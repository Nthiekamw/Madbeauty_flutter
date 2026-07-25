import {
  createServiceClient,
  fetchFcmTokenForClientProfileId,
  fetchFcmTokenForPrestataireProfileId,
  sendFcmNotification,
  verifyWebhookSecret,
  type WebhookPayload,
} from "../_shared/booking_notify.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }
  try {
    if (!verifyWebhookSecret(req)) {
      return new Response("Unauthorized", { status: 401 });
    }

    const payload = await req.json() as WebhookPayload;
    const record = payload.record;
    if (!record) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const statut = String(record["statut"] ?? "").trim();
    if (statut !== "pay_on_site" && statut !== "paid") {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const prestaId = String(record["prestataire_id"] ?? "");
    if (!prestaId) {
      return new Response(
        JSON.stringify({ ok: false, error: "prestataire_id manquant" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const supabase = createServiceClient();
    const token = await fetchFcmTokenForPrestataireProfileId(supabase, prestaId);
    if (!token) {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "no fcm_token" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const amountCents = Number(record["amount_cents"] ?? 0);
    const amountLabel = Number.isFinite(amountCents) && amountCents > 0
      ? `${(amountCents / 100).toFixed(2).replace(".", ",")} €`
      : "";

    await sendFcmNotification({
      token,
      title: "MadBeauty",
      body: amountLabel
        ? `Nouvelle commande boutique · ${amountLabel}`
        : "Nouvelle commande boutique",
      data: {
        type: "boutique_order_created",
        commande_id: String(record["id"] ?? ""),
        status: statut,
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
