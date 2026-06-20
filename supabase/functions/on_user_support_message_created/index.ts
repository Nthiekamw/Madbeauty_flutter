import {
  createServiceClient,
  sendFcmNotification,
  verifyWebhookSecret,
  type WebhookPayload,
} from "../_shared/booking_notify.ts";
import { fetchAdminFcmTargets } from "../_shared/bug_report_notify.ts";

function previewBody(raw: unknown, maxLen = 120): string {
  const text = String(raw ?? "").trim();
  if (!text) return "Nouveau message";
  if (text.length <= maxLen) return text;
  return `${text.slice(0, maxLen - 1)}…`;
}

async function resolveUserAudienceRole(
  supabase: ReturnType<typeof createServiceClient>,
  userId: string,
): Promise<"client" | "prestataire"> {
  const { data: roles } = await supabase
    .from("user_roles")
    .select("role")
    .eq("user_id", userId);

  const set = new Set(
    (roles ?? [])
      .map((row) => String(row.role ?? "").trim().toLowerCase())
      .filter((role) => role.length > 0),
  );

  if (set.has("prestataire") && !set.has("client")) {
    return "prestataire";
  }
  return "client";
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
    const threadId = String(record["thread_id"] ?? "");
    const content = previewBody(record["content"]);
    if (!senderId || !threadId) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createServiceClient();
    const { data: thread } = await supabase
      .from("user_support_threads")
      .select("user_id")
      .eq("id", threadId)
      .maybeSingle();

    if (!thread) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    const threadUserId = String(thread.user_id ?? "");
    if (!threadUserId) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    let pushed = 0;

    if (senderId === threadUserId) {
      const targets = await fetchAdminFcmTargets(supabase);
      for (const target of targets) {
        const ok = await sendFcmNotification({
          token: target.token,
          title: "Support utilisateur",
          body: content,
          data: {
            type: "user_support_message",
            thread_id: threadId,
            nav: "user_support_chat",
            role: "admin",
            audience: "admin",
          },
        });
        if (ok) pushed += 1;
      }
    } else {
      const { data: profile } = await supabase
        .from("user_profiles")
        .select("fcm_token")
        .eq("user_id", threadUserId)
        .maybeSingle();

      const token = String(profile?.fcm_token ?? "").trim();
      if (token) {
        const role = await resolveUserAudienceRole(supabase, threadUserId);
        const ok = await sendFcmNotification({
          token,
          title: "MadBeauty Support",
          body: content,
          data: {
            type: "user_support_message",
            thread_id: threadId,
            nav: "user_support_chat",
            role,
            audience: role,
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
