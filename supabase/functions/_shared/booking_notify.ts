/** Partagé entre les fonctions de notification réservation → FCM. */
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

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
  return { ...parsed as ServiceAccount, project_id: projectId };
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
