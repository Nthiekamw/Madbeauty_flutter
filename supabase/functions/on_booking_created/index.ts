import {
  createServiceClient,
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

    const prestataireId = String(record["prestataire_id"] ?? "");
    if (!prestataireId) {
      return new Response(JSON.stringify({ ok: false, error: "pas de prestataire" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createServiceClient();

    const { data: prest } = await supabase
      .from("prestataire_profiles")
      .select("user_id")
      .eq("id", prestataireId)
      .maybeSingle();

    const userId = prest?.user_id as string | undefined;
    if (!userId) {
      return new Response(JSON.stringify({ ok: true, skipped: true, reason: "no user_id" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const { data: profile } = await supabase
      .from("user_profiles")
      .select("fcm_token")
      .eq("user_id", userId)
      .maybeSingle();

    const token = profile?.fcm_token as string | null | undefined;
    if (!token) {
      return new Response(JSON.stringify({ ok: true, skipped: true, reason: "no fcm_token" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    await sendFcmNotification({
      token,
      title: "MadBeauty",
      body: "Nouvelle demande de réservation",
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
