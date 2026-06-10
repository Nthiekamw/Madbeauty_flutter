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
    if (payload.type !== "INSERT" || !record) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const action = String(record["action"] ?? "");
    if (action !== "approved" && action !== "revoked") {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "not_decision" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const prestataireId = String(record["prestataire_id"] ?? "");
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

    const note = record["note"] != null ? String(record["note"]).trim() : "";
    const isApproved = action === "approved";

    const title = isApproved
      ? "Profil vérifié"
      : "Vérification à corriger";
    const body = isApproved
      ? "Félicitations ! Ton profil prestataire est approuvé sur MadBeauty."
      : note.length > 0
      ? `L’équipe demande des corrections : ${note}`
      : "L’équipe a retiré ta vérification. Consulte ton profil pour refaire une demande.";

    await sendFcmNotification({
      token,
      title,
      body,
      data: {
        type: isApproved
          ? "prestataire_verification_approved"
          : "prestataire_verification_revoked",
        prestataire_id: prestataireId,
        event_id: String(record["id"] ?? ""),
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
