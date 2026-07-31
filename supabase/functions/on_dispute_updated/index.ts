import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  createServiceClient,
  fetchFcmTokenForClientProfileId,
  fetchFcmTokenForPrestataireProfileId,
  sendFcmNotification,
  verifyWebhookSecret,
  type WebhookPayload,
} from "../_shared/booking_notify.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }
  if (!verifyWebhookSecret(req)) {
    return jsonResponse({ error: "Unauthorized" }, 401);
  }

  try {
    const payload = (await req.json()) as WebhookPayload;
    const record = payload.record ?? {};
    const clientId = String(record["client_id"] ?? "");
    const prestaId = String(record["prestataire_id"] ?? "");
    const status = String(record["status"] ?? "");
    const disputeId = String(record["id"] ?? "");
    const type = String(payload.type ?? "INSERT");

    if (!clientId || !prestaId || !disputeId) {
      return jsonResponse({ ok: true, skipped: true });
    }

    const admin = createServiceClient();
    const clientToken = await fetchFcmTokenForClientProfileId(admin, clientId);
    const prestaToken = await fetchFcmTokenForPrestataireProfileId(
      admin,
      prestaId,
    );

    const isOpen = type === "INSERT" || status === "open";
    const resolved = status.startsWith("resolved_") || status === "closed";

    const title = isOpen && type === "INSERT"
      ? "Nouveau litige"
      : resolved
      ? "Litige mis à jour"
      : "Litige en cours";
    const body = isOpen && type === "INSERT"
      ? "Un litige a été ouvert sur une réservation. Consulte les détails dans l’app."
      : resolved
      ? "Une décision a été prise sur ton litige. Ouvre MadBeauty pour la consulter."
      : "Le statut de ton litige a changé.";

    const data = {
      type: "booking_dispute",
      dispute_id: disputeId,
      status,
    };

    if (clientToken) {
      await sendFcmNotification({
        token: clientToken,
        title,
        body,
        data,
      });
    }
    if (prestaToken) {
      await sendFcmNotification({
        token: prestaToken,
        title,
        body,
        data,
      });
    }

    return jsonResponse({ ok: true });
  } catch (e) {
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
