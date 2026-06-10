import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { sendFcmNotification } from "../_shared/booking_notify.ts";
import {
  requireAuthUser,
  serviceClient,
} from "../_shared/stripe_booking.ts";

type Audience = "all" | "client" | "prestataire" | "user";

type NavTarget =
  | "none"
  | "client_home"
  | "client_reservations"
  | "client_search"
  | "client_messages"
  | "prestataire_dashboard"
  | "prestataire_subscription"
  | "prestataire_profile_edit"
  | "booking";

interface Body {
  title?: string;
  body?: string;
  audience?: string;
  userId?: string;
  dryRun?: boolean;
  excludeBanned?: boolean;
  nav?: string;
  prestataireId?: string;
  serviceId?: string;
}

const TITLE_MAX = 120;
const BODY_MAX = 500;

const VALID_NAV: NavTarget[] = [
  "none",
  "client_home",
  "client_reservations",
  "client_search",
  "client_messages",
  "prestataire_dashboard",
  "prestataire_subscription",
  "prestataire_profile_edit",
  "booking",
];

async function isAdminUser(
  supabase: ReturnType<typeof serviceClient>,
  userId: string,
): Promise<boolean> {
  const { data, error } = await supabase.rpc("is_admin_user", {
    p_user_id: userId,
  });
  if (error) {
    console.error("is_admin_user:", error);
    return false;
  }
  return data === true;
}

async function adminUserIds(
  supabase: ReturnType<typeof serviceClient>,
): Promise<Set<string>> {
  const { data, error } = await supabase
    .from("user_roles")
    .select("user_id")
    .eq("role", "admin");
  if (error) {
    console.error("admin roles:", error);
    return new Set();
  }
  return new Set(
    (data ?? []).map((r) => String(r.user_id)).filter(Boolean),
  );
}

async function roleUserIds(
  supabase: ReturnType<typeof serviceClient>,
  role: "client" | "prestataire",
): Promise<string[]> {
  const { data, error } = await supabase
    .from("user_roles")
    .select("user_id")
    .eq("role", role);
  if (error) {
    console.error(`role ${role}:`, error);
    return [];
  }
  return (data ?? []).map((r) => String(r.user_id)).filter(Boolean);
}

async function fetchRecipientTokens(
  supabase: ReturnType<typeof serviceClient>,
  audience: Audience,
  opts: { userId?: string; excludeBanned: boolean },
): Promise<Array<{ user_id: string; fcm_token: string }>> {
  const admins = await adminUserIds(supabase);
  const recipients: Array<{ user_id: string; fcm_token: string }> = [];

  const profileSelect = "user_id, fcm_token, is_banned";

  if (audience === "user") {
    if (!opts.userId) return [];
    let query = supabase
      .from("user_profiles")
      .select(profileSelect)
      .eq("user_id", opts.userId)
      .not("fcm_token", "is", null);
    if (opts.excludeBanned) {
      query = query.eq("is_banned", false);
    }
    const { data, error } = await query.maybeSingle();
    if (error) {
      console.error("user profile:", error);
      return [];
    }
    if (data?.fcm_token) {
      recipients.push({
        user_id: String(data.user_id),
        fcm_token: String(data.fcm_token),
      });
    }
    return recipients;
  }

  let allowedIds: Set<string> | null = null;
  if (audience === "client" || audience === "prestataire") {
    const ids = await roleUserIds(supabase, audience);
    allowedIds = new Set(ids);
    if (allowedIds.size === 0) return [];
  }

  const pageSize = 500;
  let from = 0;
  while (true) {
    let query = supabase
      .from("user_profiles")
      .select(profileSelect)
      .not("fcm_token", "is", null);
    if (opts.excludeBanned) {
      query = query.eq("is_banned", false);
    }
    const { data, error } = await query.range(from, from + pageSize - 1);

    if (error) {
      console.error("user_profiles page:", error);
      break;
    }
    const rows = data ?? [];
    for (const row of rows) {
      const uid = String(row.user_id ?? "");
      const token = String(row.fcm_token ?? "").trim();
      if (!uid || !token) continue;
      if (admins.has(uid)) continue;
      if (allowedIds && !allowedIds.has(uid)) continue;
      recipients.push({ user_id: uid, fcm_token: token });
    }
    if (rows.length < pageSize) break;
    from += pageSize;
  }

  return recipients;
}

function buildPushData(opts: {
  nav: NavTarget;
  prestataireId?: string;
  serviceId?: string;
}): Record<string, string> {
  const data: Record<string, string> = {
    type: "admin_broadcast",
    nav: opts.nav,
  };
  if (opts.prestataireId) {
    data.prestataire_id = opts.prestataireId;
  }
  if (opts.serviceId) {
    data.service_id = opts.serviceId;
  }
  return data;
}

async function sendFcmWithResult(opts: {
  token: string;
  title: string;
  body: string;
  data: Record<string, string>;
}): Promise<boolean> {
  try {
    return await sendFcmNotification({
      token: opts.token,
      title: opts.title,
      body: opts.body,
      data: opts.data,
    });
  } catch (e) {
    console.error("FCM send:", e);
    return false;
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }

  try {
    const { user } = await requireAuthUser(req);
    const admin = serviceClient();

    if (!(await isAdminUser(admin, user.id))) {
      return jsonResponse({ error: "Accès refusé" }, 403);
    }

    let payload: Body = {};
    try {
      payload = (await req.json()) as Body;
    } catch {
      return jsonResponse({ error: "Corps JSON invalide" }, 400);
    }

    const title = String(payload.title ?? "").trim();
    const body = String(payload.body ?? "").trim();
    const audience = String(payload.audience ?? "all").trim() as Audience;
    const userId = payload.userId ? String(payload.userId).trim() : undefined;
    const dryRun = payload.dryRun === true;
    const excludeBanned = payload.excludeBanned !== false;
    const navRaw = String(payload.nav ?? "none").trim() as NavTarget;
    const nav = VALID_NAV.includes(navRaw) ? navRaw : "none";
    const prestataireId = payload.prestataireId
      ? String(payload.prestataireId).trim()
      : undefined;
    const serviceId = payload.serviceId
      ? String(payload.serviceId).trim()
      : undefined;

    if (!dryRun) {
      if (!title) {
        return jsonResponse({ error: "Le titre est obligatoire" }, 400);
      }
      if (!body) {
        return jsonResponse({ error: "Le message est obligatoire" }, 400);
      }
      if (title.length > TITLE_MAX) {
        return jsonResponse({
          error: `Titre trop long (max ${TITLE_MAX} caractères)`,
        }, 400);
      }
      if (body.length > BODY_MAX) {
        return jsonResponse({
          error: `Message trop long (max ${BODY_MAX} caractères)`,
        }, 400);
      }
      if (nav === "booking" && !prestataireId) {
        return jsonResponse({
          error: "prestataireId requis pour ouvrir l’écran de réservation",
        }, 400);
      }
    }

    const validAudiences: Audience[] = ["all", "client", "prestataire", "user"];
    if (!validAudiences.includes(audience)) {
      return jsonResponse({ error: "Audience invalide" }, 400);
    }
    if (audience === "user" && !userId) {
      return jsonResponse({ error: "userId requis pour l’audience user" }, 400);
    }

    const recipients = await fetchRecipientTokens(admin, audience, {
      userId,
      excludeBanned,
    });
    const recipientCount = recipients.length;

    if (dryRun) {
      return jsonResponse({
        ok: true,
        dryRun: true,
        recipients: recipientCount,
        audience,
        excludeBanned,
        nav,
      });
    }

    const pushData = buildPushData({ nav, prestataireId, serviceId });

    let sent = 0;
    let failed = 0;
    for (const row of recipients) {
      const ok = await sendFcmWithResult({
        token: row.fcm_token,
        title,
        body,
        data: pushData,
      });
      if (ok) sent += 1;
      else failed += 1;
    }

    const { error: auditError } = await admin.from("admin_audit_log").insert({
      actor_user_id: user.id,
      action: "send_push",
      entity_type: "push_broadcast",
      entity_id: audience === "user" ? (userId ?? "user") : audience,
      metadata: {
        title,
        body,
        audience,
        user_id: userId ?? null,
        recipients: recipientCount,
        sent,
        failed,
        exclude_banned: excludeBanned,
        nav,
        prestataire_id: prestataireId ?? null,
        service_id: serviceId ?? null,
      },
    });
    if (auditError) {
      console.error("audit log:", auditError);
    }

    return jsonResponse({
      ok: true,
      dryRun: false,
      recipients: recipientCount,
      sent,
      failed,
      audience,
      excludeBanned,
      nav,
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ ok: false, error: String(e) }, 500);
  }
});
