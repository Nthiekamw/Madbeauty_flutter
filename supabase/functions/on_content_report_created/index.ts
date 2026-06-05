import {
  sendContentReportEmail,
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

    const result = await sendContentReportEmail({
      reportId: String(record["id"]),
      reporterUserId: String(record["reporter_user_id"] ?? ""),
      targetType: String(record["target_type"] ?? ""),
      targetId: String(record["target_id"] ?? ""),
      reason: String(record["reason"] ?? ""),
      details: record["details"] != null ? String(record["details"]) : null,
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
