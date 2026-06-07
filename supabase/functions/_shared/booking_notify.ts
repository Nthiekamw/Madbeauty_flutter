/// <reference path="../types.d.ts" />
/** Partagé entre les fonctions de notification réservation → FCM. */
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9.15.1";

export interface WebhookPayload {
  type?: string;
  table?: string;
  schema?: string;
  record?: Record<string, unknown> | null;
  old_record?: Record<string, unknown> | null;
}

export function verifyWebhookSecret(req: Request): boolean {
  const expected = Deno.env.get("BOOKING_WEBHOOK_SECRET");
  if (!expected) {
    console.warn(
      "BOOKING_WEBHOOK_SECRET non défini — accepté (configurer pour la prod).",
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

export function createServiceClient() {
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !key) {
    throw new Error("SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY manquant");
  }
  return createClient(url, key);
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  project_id?: string;
}

function loadServiceAccount(): ServiceAccount & { project_id: string } {
  const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
  if (!raw) {
    throw new Error(
      "FIREBASE_SERVICE_ACCOUNT_JSON manquant — JSON du compte de service Firebase en une ligne (échapper les retours ligne de la clé avec \\n).",
    );
  }
  let parsed = JSON.parse(raw) as Record<string, string>;
  if (typeof parsed.private_key === "string") {
    parsed = {
      ...parsed,
      private_key: parsed.private_key.replace(/\\n/g, "\n"),
    };
  }
  const projectId = parsed.project_id;
  const client_email = parsed.client_email;
  const private_key = parsed.private_key;
  if (!projectId || !client_email || !private_key) {
    throw new Error(
      "FIREBASE_SERVICE_ACCOUNT_JSON invalide (project_id, client_email, private_key).",
    );
  }
  return { ...(parsed as unknown as ServiceAccount), project_id: projectId };
}

async function fetchAccessToken(sa: ServiceAccount): Promise<string> {
  const jwtAuth = new JWT({
    email: sa.client_email,
    key: sa.private_key.replace(/\\n/g, "\n"),
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });
  const at = await jwtAuth.getAccessToken();
  if (!at.token) throw new Error("Impossible d'obtenir un access_token FCM.");
  return at.token;
}

export async function sendFcmNotification(opts: {
  token: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}) {
  const sa = loadServiceAccount();
  const accessToken = await fetchAccessToken(sa);
  const projectId = sa.project_id!;
  const url =
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token: opts.token,
        notification: {
          title: opts.title,
          body: opts.body,
        },
        ...(opts.data ? { data: opts.data } : {}),
        android: { priority: "HIGH" },
        apns: { headers: { "apns-priority": "10" } },
      },
    }),
  });
  if (!res.ok) {
    const txt = await res.text();
    console.error(`FCM erreur ${res.status}: ${txt}`);
  }
}

export function normalizeStatut(raw: unknown): string {
  if (raw == null) return "";
  return String(raw).trim().toLowerCase().replaceAll("é", "e").replaceAll(
    "è",
    "e",
  );
}

export function statusIsConfirmed(norm: string): boolean {
  return ["confirmee", "confirmed", "validee", "valide"].includes(norm);
}

export function statusIsCancelled(norm: string): boolean {
  return ["annulee", "cancelled", "canceled", "refusee", "refused"].includes(
    norm,
  );
}

export function statusIsActiveReservation(norm: string): boolean {
  return [
    "en_attente",
    "pending",
    "confirmee",
    "confirmed",
    "validee",
    "valide",
  ].includes(norm);
}

/** Date calendaire (Europe/Paris) pour matcher `slot_waitlist.date_jour`. */
export function dateJourParisFromIso(iso: unknown): string | null {
  if (iso == null) return null;
  const d = new Date(String(iso));
  if (Number.isNaN(d.getTime())) return null;
  return new Intl.DateTimeFormat("en-CA", { timeZone: "Europe/Paris" }).format(
    d,
  );
}

function formatDateFr(isoDate: string): string {
  const [y, m, d] = isoDate.split("-").map(Number);
  if (!y || !m || !d) return isoDate;
  const dt = new Date(Date.UTC(y, m - 1, d));
  return new Intl.DateTimeFormat("fr-FR", {
    day: "numeric",
    month: "long",
    timeZone: "UTC",
  }).format(dt);
}

/** Notifie les clientes en liste d'attente après libération d'un créneau. */
export async function notifySlotWaitlistForFreedDay(
  supabase: ReturnType<typeof createServiceClient>,
  opts: {
    prestataireId: string;
    dateHeureIso: unknown;
    excludeClientId?: string;
  },
): Promise<{ notified: number }> {
  const dateJour = dateJourParisFromIso(opts.dateHeureIso);
  if (!dateJour) return { notified: 0 };

  const { data: presta } = await supabase
    .from("prestataire_profiles")
    .select("nom_affiche, nom_salon")
    .eq("id", opts.prestataireId)
    .maybeSingle();

  const prestaName = String(
    presta?.nom_affiche ?? presta?.nom_salon ?? "ton prestataire",
  ).trim() || "ton prestataire";

  const { data: rows, error } = await supabase
    .from("slot_waitlist")
    .select("id, client_id, service_id")
    .eq("prestataire_id", opts.prestataireId)
    .eq("date_jour", dateJour);

  if (error) {
    console.error("slot_waitlist select:", error);
    return { notified: 0 };
  }

  let notified = 0;
  const dateLabel = formatDateFr(dateJour);

  for (const row of rows ?? []) {
    const clientId = String(row.client_id ?? "");
    if (!clientId) continue;
    if (opts.excludeClientId && clientId === opts.excludeClientId) continue;

    const { data: cli } = await supabase
      .from("client_profiles")
      .select("user_id")
      .eq("id", clientId)
      .maybeSingle();

    const userId = cli?.user_id as string | undefined;
    if (!userId) continue;

    const { data: profile } = await supabase
      .from("user_profiles")
      .select("fcm_token")
      .eq("user_id", userId)
      .maybeSingle();

    const token = profile?.fcm_token as string | null | undefined;
    if (!token) continue;

    const serviceId = String(row.service_id ?? "");
    await sendFcmNotification({
      token,
      title: "Créneau disponible",
      body:
        `Un créneau s'est libéré chez ${prestaName} le ${dateLabel}. Réserve vite !`,
      data: {
        type: "slot_waitlist",
        prestataire_id: opts.prestataireId,
        service_id: serviceId,
        date_jour: dateJour,
      },
    });

    await supabase.from("slot_waitlist").delete().eq("id", row.id);
    notified += 1;
  }

  return { notified };
}
