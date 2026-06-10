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
    if (
      payload.type !== "INSERT" ||
      !record ||
      String(record["id"] ?? "") === ""
    ) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createServiceClient();
    const reservationId = String(record["id"]);
    const prestataireId = String(record["prestataire_id"] ?? "");
    const clientId = String(record["client_id"] ?? "");

    let sentPrestataire = false;
    let sentClient = false;

    if (prestataireId) {
      const token = await fetchFcmTokenForPrestataireProfileId(
        supabase,
        prestataireId,
      );
      if (token) {
        await sendFcmNotification({
          token,
          title: "MadBeauty",
          body: "Nouvelle demande de réservation",
          data: {
            type: "booking_created",
            reservation_id: reservationId,
            role: "prestataire",
          },
        });
        sentPrestataire = true;
      }
    }

    if (clientId) {
      const token = await fetchFcmTokenForClientProfileId(supabase, clientId);
      if (token) {
        await sendFcmNotification({
          token,
          title: "MadBeauty",
          body: "Demande envoyée — en attente de confirmation",
          data: {
            type: "booking_created",
            reservation_id: reservationId,
            role: "client",
          },
        });
        sentClient = true;
      }
    }

    return new Response(
      JSON.stringify({
        ok: true,
        sent_prestataire: sentPrestataire,
        sent_client: sentClient,
      }),
      { headers: { "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ ok: false, error: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
