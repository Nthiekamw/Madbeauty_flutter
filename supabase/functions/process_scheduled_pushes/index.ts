import {
  clearStaleFcmTokenForUser,
  createServiceClient,
  isFcmTokenUnregisteredError,
  isFirebaseCredentialError,
  sendFcmNotification,
} from "../_shared/booking_notify.ts";

const BATCH_LIMIT = 40;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
      },
    });
  }
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  try {
    const supabase = createServiceClient();
    const nowIso = new Date().toISOString();

    const { data: due, error } = await supabase
      .from("scheduled_pushes")
      .select(
        "id, type, client_id, prestataire_id, reservation_id, payload, send_at",
      )
      .eq("status", "pending")
      .lte("send_at", nowIso)
      .order("send_at", { ascending: true })
      .limit(BATCH_LIMIT);

    if (error) {
      console.error("scheduled_pushes select", error);
      return json({ ok: false, error: error.message }, 500);
    }

    const rows = due ?? [];
    let sent = 0;
    let skipped = 0;
    let failed = 0;

    for (const row of rows) {
      const id = String(row.id ?? "");
      const type = String(row.type ?? "");
      const clientId = String(row.client_id ?? "");
      if (!id || !clientId) {
        skipped++;
        continue;
      }

      // Claim atomique (idempotence)
      const { data: claimed, error: claimErr } = await supabase
        .from("scheduled_pushes")
        .update({ status: "sent", sent_at: new Date().toISOString() })
        .eq("id", id)
        .eq("status", "pending")
        .select("id")
        .maybeSingle();

      if (claimErr || !claimed) {
        skipped++;
        continue;
      }

      const payload = (row.payload ?? {}) as Record<string, unknown>;
      const prestataireId = String(
        row.prestataire_id ?? payload.prestataire_id ?? "",
      );
      const serviceId = String(payload.service_id ?? "");
      const reservationId = String(
        row.reservation_id ?? payload.reservation_id ?? "",
      );

      const { title, body, dataType } = copyForType(type, payload);

      const { data: cli } = await supabase
        .from("client_profiles")
        .select("user_id")
        .eq("id", clientId)
        .maybeSingle();
      const userId = cli?.user_id as string | undefined;
      if (!userId) {
        skipped++;
        continue;
      }

      const { data: profile } = await supabase
        .from("user_profiles")
        .select("fcm_token")
        .eq("user_id", userId)
        .maybeSingle();
      const token = profile?.fcm_token as string | null | undefined;
      if (!token) {
        skipped++;
        if (type === "rebook_reminder") {
          await markRebookSent(supabase, id);
        }
        continue;
      }

      try {
        await sendFcmNotification({
          token,
          title,
          body,
          data: {
            type: dataType,
            reservation_id: reservationId,
            prestataire_id: prestataireId,
            service_id: serviceId,
            role: "client",
          },
        });
        sent++;
        if (type === "rebook_reminder") {
          await markRebookSent(supabase, id);
        }
      } catch (e) {
        const msg = String(e);
        console.error("process_scheduled_pushes FCM", id, msg);
        failed++;
        await supabase
          .from("scheduled_pushes")
          .update({ status: "failed" })
          .eq("id", id);

        if (isFcmTokenUnregisteredError(msg)) {
          await clearStaleFcmTokenForUser(supabase, { userId, token });
        } else if (isFirebaseCredentialError(msg)) {
          // Remet en pending pour retry après correction des secrets
          await supabase
            .from("scheduled_pushes")
            .update({ status: "pending", sent_at: null })
            .eq("id", id);
        }
      }
    }

    return json({ ok: true, processed: rows.length, sent, skipped, failed });
  } catch (e) {
    console.error(e);
    return json({ ok: false, error: String(e) }, 500);
  }
});

function copyForType(
  type: string,
  payload: Record<string, unknown>,
): { title: string; body: string; dataType: string } {
  if (type === "aftercare") {
    return {
      title: "MadBeauty",
      body: "Comment s’est passé ton rendez-vous ? Laisse un avis ou rebooke quand tu veux.",
      dataType: "aftercare",
    };
  }
  if (type === "rebook_reminder") {
    const weeks = Number(payload.interval_weeks ?? 0);
    const weeksLabel = weeks === 6 ? "6 semaines" : "4 semaines";
    return {
      title: "MadBeauty",
      body: `Il y a ${weeksLabel} : envie de rebooker chez ton salon ?`,
      dataType: "rebook_reminder",
    };
  }
  return {
    title: "MadBeauty",
    body: "Tu as une notification MadBeauty.",
    dataType: type || "scheduled_push",
  };
}

// deno-lint-ignore no-explicit-any
async function markRebookSent(supabase: any, scheduledPushId: string) {
  await supabase
    .from("booking_rebook_reminders")
    .update({ status: "sent" })
    .eq("scheduled_push_id", scheduledPushId)
    .eq("status", "scheduled");
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
