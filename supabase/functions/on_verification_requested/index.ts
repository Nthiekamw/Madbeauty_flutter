import {
  sendVerificationRequestEmail,
  verifyReportWebhookSecret,
  type WebhookPayload,
} from "../_shared/admin_notify.ts";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }
  try {
    if (!verifyReportWebhookSecret(req)) {
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

    if (String(record["action"] ?? "") !== "requested") {
      return new Response(
        JSON.stringify({ ok: true, skipped: true, reason: "not_requested" }),
        { headers: { "Content-Type": "application/json" } },
      );
    }

    const prestataireId = String(record["prestataire_id"] ?? "");
    let nomSalon: string | null = null;
    let ville: string | null = null;
    let displayName: string | null = null;

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (supabaseUrl && serviceKey && prestataireId) {
      const profileRes = await fetch(
        `${supabaseUrl}/rest/v1/prestataire_profiles?id=eq.${prestataireId}&select=nom_salon,ville,user_id`,
        {
          headers: {
            apikey: serviceKey,
            Authorization: `Bearer ${serviceKey}`,
          },
        },
      );
      if (profileRes.ok) {
        const rows = await profileRes.json() as Array<Record<string, unknown>>;
        const row = rows[0];
        if (row) {
          nomSalon = row["nom_salon"] != null
            ? String(row["nom_salon"])
            : null;
          ville = row["ville"] != null ? String(row["ville"]) : null;
          const userId = row["user_id"] != null
            ? String(row["user_id"])
            : "";
          if (userId) {
            const userRes = await fetch(
              `${supabaseUrl}/rest/v1/user_profiles?user_id=eq.${userId}&select=prenom,nom`,
              {
                headers: {
                  apikey: serviceKey,
                  Authorization: `Bearer ${serviceKey}`,
                },
              },
            );
            if (userRes.ok) {
              const users = await userRes.json() as Array<
                Record<string, unknown>
              >;
              const u = users[0];
              if (u) {
                displayName = [
                  u["prenom"] != null ? String(u["prenom"]) : "",
                  u["nom"] != null ? String(u["nom"]) : "",
                ].join(" ").trim() || null;
              }
            }
          }
        }
      }
    }

    const result = await sendVerificationRequestEmail({
      eventId: String(record["id"]),
      prestataireId,
      nomSalon,
      ville,
      displayName,
      actorUserId: String(record["actor_user_id"] ?? ""),
      createdAt: record["created_at"] != null
        ? String(record["created_at"])
        : null,
    });

    return new Response(JSON.stringify({ ok: true, email: result }), {
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
