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
      String(record["client_id"] ?? "") === "" ||
      String(record["prestataire_id"] ?? "") === ""
    ) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const clientId = String(record["client_id"]);
    const prestataireId = String(record["prestataire_id"]);
    const supabase = createServiceClient();

    const { data: prestaRow } = await supabase
      .from("prestataire_profiles")
      .select("user_id, nom_salon")
      .eq("id", prestataireId)
      .maybeSingle();

    const prestaUserId = prestaRow?.user_id as string | undefined;
    if (!prestaUserId) {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "no prestataire" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const { data: profile } = await supabase
      .from("user_profiles")
      .select("fcm_token")
      .eq("user_id", prestaUserId)
      .maybeSingle();

    const token = profile?.fcm_token as string | null | undefined;
    if (!token) {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "no fcm_token" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const storedName = record["client_display_name"] as string | undefined;
    const clientName = storedName?.trim() || "Une cliente";

    await sendFcmNotification({
      token,
      title: "Nouveau like sur ton profil",
      body: `${clientName} a aimé ton profil MadBeauty.`,
      data: {
        type: "prestataire_like",
        prestataire_id: prestataireId,
        client_id: clientId,
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
