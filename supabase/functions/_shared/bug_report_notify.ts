/// <reference path="../types.d.ts" />
/** Notifications push + e-mail pour les signalements de bugs. */
import {
  sendContentReportEmail,
  verifyReportWebhookSecret,
  type WebhookPayload,
} from "./admin_notify.ts";
import {
  createServiceClient,
  sendFcmNotification,
} from "./booking_notify.ts";

export { verifyReportWebhookSecret };
export type { WebhookPayload };

type ServiceSupabase = ReturnType<typeof createServiceClient>;

const CATEGORY_LABELS: Record<string, string> = {
  auth: "Connexion",
  booking: "Réservation",
  payment: "Paiement",
  messaging: "Messagerie",
  profile: "Profil",
  other: "Autre",
};

export function categoryLabel(raw: string): string {
  return CATEGORY_LABELS[raw] ?? raw;
}

export async function fetchAdminFcmTargets(
  supabase: ServiceSupabase,
): Promise<Array<{ userId: string; token: string }>> {
  const { data: roles, error: rolesError } = await supabase
    .from("user_roles")
    .select("user_id")
    .eq("role", "admin");

  if (rolesError) {
    console.error("user_roles admin:", rolesError);
    return [];
  }

  const userIds = [
    ...new Set(
      (roles ?? [])
        .map((r) => String(r.user_id ?? ""))
        .filter((id) => id.length > 0),
    ),
  ];

  if (userIds.length === 0) return [];

  const { data: profiles, error: profilesError } = await supabase
    .from("user_profiles")
    .select("user_id, fcm_token")
    .in("user_id", userIds);

  if (profilesError) {
    console.error("user_profiles fcm:", profilesError);
    return [];
  }

  const out: Array<{ userId: string; token: string }> = [];
  for (const row of profiles ?? []) {
    const userId = String(row.user_id ?? "");
    const token = String(row.fcm_token ?? "").trim();
    if (userId && token) out.push({ userId, token });
  }
  return out;
}

export async function notifyAdminsBugCreated(record: Record<string, unknown>) {
  const supabase = createServiceClient();
  const reportId = String(record["id"] ?? "");
  const title = String(record["title"] ?? "Bug signalé").trim();
  const category = categoryLabel(String(record["category"] ?? "other"));
  const body = `${category} — ${title}`.slice(0, 180);

  const targets = await fetchAdminFcmTargets(supabase);
  let pushed = 0;
  for (const target of targets) {
    const ok = await sendFcmNotification({
      token: target.token,
      title: "Nouveau bug signalé",
      body,
      data: {
        type: "bug_report",
        bug_report_id: reportId,
        nav: "admin_bug_reports",
      },
    });
    if (ok) pushed += 1;
  }

  const email = await sendContentReportEmail({
    reportId,
    reporterUserId: String(record["reporter_user_id"] ?? ""),
    targetType: "bug_report",
    targetId: reportId,
    reason: category,
    details: [
      `Titre : ${title}`,
      "",
      String(record["description"] ?? ""),
      record["steps_to_reproduce"]
        ? `\n\nÉtapes :\n${String(record["steps_to_reproduce"])}`
        : "",
      record["app_version"] ? `\n\nApp : ${String(record["app_version"])}` : "",
      record["platform"] ? `\nPlateforme : ${String(record["platform"])}` : "",
    ].join(""),
    createdAt: record["created_at"] != null
      ? String(record["created_at"])
      : null,
  });

  return { pushed, email };
}

export async function notifyReporterBugStatus(
  record: Record<string, unknown>,
  oldRecord: Record<string, unknown> | null | undefined,
) {
  const newStatus = String(record["status"] ?? "");
  const oldStatus = String(oldRecord?.["status"] ?? "");
  if (newStatus === oldStatus) {
    return { skipped: true, reason: "status_unchanged" };
  }
  if (newStatus !== "resolved" && newStatus !== "closed") {
    return { skipped: true, reason: "status_not_terminal" };
  }

  const reporterUserId = String(record["reporter_user_id"] ?? "");
  if (!reporterUserId) {
    return { skipped: true, reason: "no_reporter" };
  }

  const supabase = createServiceClient();
  const { data: profile } = await supabase
    .from("user_profiles")
    .select("fcm_token")
    .eq("user_id", reporterUserId)
    .maybeSingle();

  const token = String(profile?.fcm_token ?? "").trim();
  if (!token) {
    return { skipped: true, reason: "no_fcm_token" };
  }

  const title = String(record["title"] ?? "Ton signalement");
  const statusLabel = newStatus === "resolved" ? "résolu" : "classé";
  const note = String(record["reporter_message"] ?? "").trim();
  const body = note.length > 0
    ? `« ${title} » a été ${statusLabel}. ${note}`.slice(0, 180)
    : `« ${title} » a été ${statusLabel} par l'équipe MadBeauty.`;

  const ok = await sendFcmNotification({
    token,
    title: "Signalement de bug traité",
    body,
    data: {
      type: "bug_report_status",
      bug_report_id: String(record["id"] ?? ""),
      nav: "my_bug_reports",
    },
  });

  return { pushed: ok ? 1 : 0 };
}
