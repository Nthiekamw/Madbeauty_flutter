/// <reference path="../types.d.ts" />
/** Notifications e-mail équipe (signalements, modération). */

export interface WebhookPayload {
  type?: string;
  table?: string;
  schema?: string;
  record?: Record<string, unknown> | null;
  old_record?: Record<string, unknown> | null;
}

export function verifyReportWebhookSecret(req: Request): boolean {
  const expected =
    Deno.env.get("CONTENT_REPORT_WEBHOOK_SECRET") ??
      Deno.env.get("BOOKING_WEBHOOK_SECRET");
  if (!expected) {
    console.warn(
      "CONTENT_REPORT_WEBHOOK_SECRET non défini — accepté (configurer pour la prod).",
    );
    return true;
  }
  const provided =
    req.headers.get("x-webhook-secret") ?? req.headers.get("X-Webhook-Secret") ??
      "";
  const enc = new TextEncoder();
  const a = enc.encode(provided);
  const b = enc.encode(expected);
  if (a.length !== b.length) return false;
  return crypto.timingSafeEqual(a, b);
}

function parseNotifyEmails(): string[] {
  const raw =
    Deno.env.get("CONTENT_REPORT_NOTIFY_EMAILS") ??
      Deno.env.get("ADMIN_NOTIFY_EMAILS") ??
      "";
  return raw
    .split(",")
    .map((e) => e.trim())
    .filter((e) => e.length > 0 && e.includes("@"));
}

export interface ContentReportEmailInput {
  reportId: string;
  targetType: string;
  targetId: string;
  reason: string;
  details?: string | null;
  reporterUserId: string;
  createdAt?: string | null;
}

export async function sendContentReportEmail(
  input: ContentReportEmailInput,
): Promise<{ sent: boolean; reason?: string }> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  const recipients = parseNotifyEmails();
  if (!apiKey) {
    console.warn("RESEND_API_KEY manquant — e-mail signalement ignoré.");
    return { sent: false, reason: "no_resend_key" };
  }
  if (recipients.length === 0) {
    console.warn(
      "CONTENT_REPORT_NOTIFY_EMAILS vide — e-mail signalement ignoré.",
    );
    return { sent: false, reason: "no_recipients" };
  }

  const from = Deno.env.get("CONTENT_REPORT_MAIL_FROM") ??
    "MadBeauty <noreply@madbeauty.app>";
  const created = input.createdAt
    ? new Date(input.createdAt).toLocaleString("fr-FR", {
      timeZone: "Europe/Paris",
    })
    : "—";
  const details = (input.details ?? "").trim();
  const targetLabels: Record<string, string> = {
    prestataire_profile: "Profil prestataire",
    conversation: "Conversation",
    message: "Message",
  };
  const targetLabel = targetLabels[input.targetType] ?? input.targetType;

  const html = `
    <h2>Nouveau signalement MadBeauty</h2>
    <p><strong>Date :</strong> ${escapeHtml(created)}</p>
    <p><strong>ID :</strong> ${escapeHtml(input.reportId)}</p>
    <p><strong>Type :</strong> ${escapeHtml(targetLabel)}</p>
    <p><strong>Cible :</strong> ${escapeHtml(input.targetId)}</p>
    <p><strong>Motif :</strong> ${escapeHtml(input.reason)}</p>
    ${
    details
      ? `<p><strong>Détails :</strong><br>${escapeHtml(details).replace(/\n/g, "<br>")}</p>`
      : ""
  }
    <p><strong>Signaleur (user_id) :</strong> ${escapeHtml(input.reporterUserId)}</p>
    <p style="color:#666;font-size:12px;">Consulte le back-office admin dans l’app pour traiter ce signalement.</p>
  `.trim();

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to: recipients,
      subject: `[MadBeauty] Nouveau signalement — ${targetLabel}`,
      html,
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Resend ${res.status}: ${body}`);
  }

  return { sent: true };
}

export interface VerificationRequestEmailInput {
  eventId: string;
  prestataireId: string;
  nomSalon?: string | null;
  ville?: string | null;
  displayName?: string | null;
  actorUserId: string;
  createdAt?: string | null;
}

export async function sendVerificationRequestEmail(
  input: VerificationRequestEmailInput,
): Promise<{ sent: boolean; reason?: string }> {
  const apiKey = Deno.env.get("RESEND_API_KEY");
  const recipients = parseNotifyEmails();
  if (!apiKey) {
    console.warn("RESEND_API_KEY manquant — e-mail vérification ignoré.");
    return { sent: false, reason: "no_resend_key" };
  }
  if (recipients.length === 0) {
    console.warn(
      "CONTENT_REPORT_NOTIFY_EMAILS / ADMIN_NOTIFY_EMAILS vide — e-mail vérification ignoré.",
    );
    return { sent: false, reason: "no_recipients" };
  }

  const from = Deno.env.get("CONTENT_REPORT_MAIL_FROM") ??
    "MadBeauty <noreply@madbeauty.app>";
  const created = input.createdAt
    ? new Date(input.createdAt).toLocaleString("fr-FR", {
      timeZone: "Europe/Paris",
    })
    : "—";
  const salon = (input.nomSalon ?? "").trim() || "—";
  const ville = (input.ville ?? "").trim() || "—";
  const name = (input.displayName ?? "").trim() || "—";

  const html = `
    <h2>Demande de vérification prestataire</h2>
    <p><strong>Date :</strong> ${escapeHtml(created)}</p>
    <p><strong>Salon :</strong> ${escapeHtml(salon)}</p>
    <p><strong>Ville :</strong> ${escapeHtml(ville)}</p>
    <p><strong>Contact :</strong> ${escapeHtml(name)}</p>
    <p><strong>Prestataire ID :</strong> ${escapeHtml(input.prestataireId)}</p>
    <p><strong>User ID :</strong> ${escapeHtml(input.actorUserId)}</p>
    <p style="color:#666;font-size:12px;">Ouvre l’onglet Vérifications du back-office admin pour traiter cette demande.</p>
  `.trim();

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from,
      to: recipients,
      subject: `[MadBeauty] Demande de vérification — ${salon}`,
      html,
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Resend ${res.status}: ${body}`);
  }

  return { sent: true };
}

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}
