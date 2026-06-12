import {
  fetchAdminFcmTargets,
  verifyReportWebhookSecret,
  type WebhookPayload,
} from "../_shared/bug_report_notify.ts";
import {
  createServiceClient,
  sendFcmNotification,
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

    const senderId = String(record["sender_id"] ?? "");
    const bugReportId = String(record["bug_report_id"] ?? "");
    const content = previewBody(record["content"]);
    if (!senderId || !bugReportId) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createServiceClient();
    const { data: report } = await supabase
      .from("bug_reports")
      .select("reporter_user_id, title")
      .eq("id", bugReportId)
      .maybeSingle();

    if (!report) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const reporterUserId = String(report.reporter_user_id ?? "");
    const title = String(report.title ?? "Bug signalé");
    let pushed = 0;

    if (senderId === reporterUserId) {
      const targets = await fetchAdminFcmTargets(supabase);
      for (const target of targets) {
        const ok = await sendFcmNotification({
          token: target.token,
          title: "Nouveau message sur un bug",
          body: `${title} — ${content}`,
          data: {
            type: "bug_report_message",
            bug_report_id: bugReportId,
            nav: "bug_report_chat",
          },
        });
        if (ok) pushed += 1;
      }
    } else {
      const { data: profile } = await supabase
        .from("user_profiles")
        .select("fcm_token")
        .eq("user_id", reporterUserId)
        .maybeSingle();
      const token = String(profile?.fcm_token ?? "").trim();
      if (token) {
        const ok = await sendFcmNotification({
          token,
          title: "Nouveau message sur ton bug",
          body: content,
          data: {
            type: "bug_report_message",
            bug_report_id: bugReportId,
            nav: "bug_report_chat",
          },
        });
        if (ok) pushed += 1;
      }
    }

    return new Response(JSON.stringify({ ok: true, pushed }), {
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
