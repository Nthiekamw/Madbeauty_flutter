import {
  createServiceClient,
  sendFcmNotification,
  verifyWebhookSecret,
  type WebhookPayload,
} from "../_shared/booking_notify.ts";

function previewBody(raw: unknown, maxLen = 120): string {
  const text = String(raw ?? "").trim();
  if (!text) return "Nouveau message";
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
      String(record["id"] ?? "") === ""
    ) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const senderId = String(record["sender_id"] ?? "");
    const bookingId = String(record["booking_id"] ?? "");
    if (!senderId || !bookingId) {
      return new Response(
        JSON.stringify({ ok: false, error: "sender_id ou booking_id manquant" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const supabase = createServiceClient();

    const { data: reservation } = await supabase
      .from("reservations")
      .select("client_id, prestataire_id")
      .eq("id", bookingId)
      .maybeSingle();

    if (!reservation) {
      return new Response(JSON.stringify({ ok: true, skipped: true, reason: "no reservation" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const clientProfileId = String(reservation.client_id ?? "");
    const prestataireProfileId = String(reservation.prestataire_id ?? "");

    const { data: clientRow } = await supabase
      .from("client_profiles")
      .select("user_id")
      .eq("id", clientProfileId)
      .maybeSingle();

    const { data: prestaRow } = await supabase
      .from("prestataire_profiles")
      .select("user_id")
      .eq("id", prestataireProfileId)
      .maybeSingle();

    const clientUserId = clientRow?.user_id as string | undefined;
    const prestaUserId = prestaRow?.user_id as string | undefined;

    let recipientUserId: string | undefined;
    if (senderId === clientUserId) {
      recipientUserId = prestaUserId;
    } else if (senderId === prestaUserId) {
      recipientUserId = clientUserId;
    } else {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "sender not participant" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    if (!recipientUserId) {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "no recipient" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const { data: profile } = await supabase
      .from("user_profiles")
      .select("fcm_token")
      .eq("user_id", recipientUserId)
      .maybeSingle();

    const token = profile?.fcm_token as string | null | undefined;
    if (!token) {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "no fcm_token" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const body = previewBody(record["content"] ?? record["contenu"]);

    await sendFcmNotification({
      token,
      title: "MadBeauty",
      body,
      data: {
        type: "message",
        booking_id: bookingId,
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
