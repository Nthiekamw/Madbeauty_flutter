import {
  createServiceClient,
  normalizeStatut,
  notifySlotWaitlistForFreedDay,
  sendFcmNotification,
  statusIsActiveReservation,
  statusIsCancelled,
  statusIsConfirmed,
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
    const supabase = createServiceClient();

    if (payload.type === "DELETE" && payload.old_record) {
      const old = payload.old_record;
      const oldS = normalizeStatut(old["statut"]);
      let waitlistNotified = 0;
      if (statusIsActiveReservation(oldS)) {
        const prestataireId = String(old["prestataire_id"] ?? "");
        if (prestataireId) {
          const result = await notifySlotWaitlistForFreedDay(supabase, {
            prestataireId,
            dateHeureIso: old["date_heure"],
            excludeClientId: String(old["client_id"] ?? ""),
          });
          waitlistNotified = result.notified;
        }
      }
      return new Response(
        JSON.stringify({ ok: true, waitlist_notified: waitlistNotified }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const record = payload.record;
    const old = payload.old_record;
    if (payload.type !== "UPDATE" || !record || !old) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const newS = normalizeStatut(record["statut"]);
    const oldS = normalizeStatut(old["statut"]);
    if (newS === oldS) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    let title = "";
    let body = "";
    if (statusIsConfirmed(newS) && !statusIsConfirmed(oldS)) {
      title = "MadBeauty";
      body = "Votre réservation est confirmée✅";
    } else if (statusIsCancelled(newS) && !statusIsCancelled(oldS)) {
      title = "MadBeauty";
      body = "Votre réservation a été refusée";
    } else {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const clientUuid = String(record["client_id"] ?? "");
    if (!clientUuid) {
      return new Response(JSON.stringify({ ok: false, error: "client_id manquant" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    const { data: cli } = await supabase
      .from("client_profiles")
      .select("user_id")
      .eq("id", clientUuid)
      .maybeSingle();

    const userId = cli?.user_id as string | undefined;
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

    await sendFcmNotification({ token, title, body });

    let waitlistNotified = 0;
    if (
      statusIsCancelled(newS) &&
      !statusIsCancelled(oldS) &&
      statusIsActiveReservation(oldS)
    ) {
      const prestataireId = String(record["prestataire_id"] ?? "");
      if (prestataireId) {
        const result = await notifySlotWaitlistForFreedDay(supabase, {
          prestataireId,
          dateHeureIso: record["date_heure"],
          excludeClientId: String(record["client_id"] ?? ""),
        });
        waitlistNotified = result.notified;
      }
    }

    return new Response(
      JSON.stringify({ ok: true, waitlist_notified: waitlistNotified }),
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
