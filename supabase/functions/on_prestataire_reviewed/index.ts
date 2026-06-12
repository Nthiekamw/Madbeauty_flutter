import {
  createServiceClient,
  fetchFcmTokenForPrestataireProfileId,
  sendFcmNotification,
  verifyWebhookSecret,
  type WebhookPayload,
} from "../_shared/booking_notify.ts";

function previewComment(raw: unknown, maxLen = 80): string {
  const text = String(raw ?? "").trim().replace(/\s+/g, " ");
  if (!text) return "";
  if (text.length <= maxLen) return text;
  return `${text.slice(0, maxLen - 1)}…`;
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
    const record = payload.record;
    if (
      payload.type !== "INSERT" ||
      !record ||
      String(record["prestataire_id"] ?? "") === "" ||
      String(record["id"] ?? "") === ""
    ) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const prestataireId = String(record["prestataire_id"]);
    const reviewId = String(record["id"]);
    const reservationId = String(record["reservation_id"] ?? "");
    const note = Number(record["note"] ?? 0);
    if (!Number.isFinite(note) || note < 1 || note > 5) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createServiceClient();
    const token = await fetchFcmTokenForPrestataireProfileId(
      supabase,
      prestataireId,
    );
    if (!token) {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "no fcm_token" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const storedName = record["client_display_name"] as string | undefined;
    const clientName = storedName?.trim() || "Une cliente";
    const comment = previewComment(record["commentaire"]);
    const isLow = note <= 2;

    const title = isLow
      ? "Avis à améliorer sur ton profil"
      : "Nouvel avis sur ton profil";

    let body = isLow
      ? `${clientName} t'a donné ${note}/5.`
      : `${clientName} t'a laissé ${note}/5 sur MadBeauty.`;
    if (comment.length > 0) {
      body = `${body} « ${comment} »`;
    }

    await sendFcmNotification({
      token,
      title,
      body,
      data: {
        type: "prestataire_review",
        prestataire_id: prestataireId,
        review_id: reviewId,
        reservation_id: reservationId,
        note: String(note),
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
