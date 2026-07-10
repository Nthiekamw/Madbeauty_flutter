import Stripe from "npm:stripe@17.7.0";
import { createClient, type SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export function stripeClient(): Stripe {
  const key = Deno.env.get("STRIPE_SECRET_KEY");
  if (!key) throw new Error("STRIPE_SECRET_KEY manquant");
  return new Stripe(key, { apiVersion: "2024-11-20.acacia" });
}

export function serviceClient(): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL");
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !key) {
    throw new Error("SUPABASE_URL ou SUPABASE_SERVICE_ROLE_KEY manquant");
  }
  return createClient(url, key);
}

export function userClient(authHeader: string): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL");
  const anon = Deno.env.get("SUPABASE_ANON_KEY");
  if (!url || !anon) {
    throw new Error("SUPABASE_URL ou SUPABASE_ANON_KEY manquant");
  }
  return createClient(url, anon, {
    global: { headers: { Authorization: authHeader } },
  });
}

export async function requireAuthUser(req: Request) {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    throw new Response(JSON.stringify({ error: "Non authentifié" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }
  const supabase = userClient(authHeader);
  const { data, error } = await supabase.auth.getUser();
  if (error || !data.user) {
    throw new Response(JSON.stringify({ error: "Session invalide" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }
  return { supabase, user: data.user, authHeader };
}

export function startOfMinuteLocal(iso: string): Date {
  const d = new Date(iso);
  return new Date(
    d.getFullYear(),
    d.getMonth(),
    d.getDate(),
    d.getHours(),
    d.getMinutes(),
    0,
    0,
  );
}

/** Instant UTC (minute) — aligné avec le payload Flutter `toUtc().toIso8601String()`. */
export function normalizeBookingInstant(iso: string): string {
  const trimmed = iso.trim();
  if (!trimmed) return trimmed;
  const d = new Date(trimmed);
  if (Number.isNaN(d.getTime())) return trimmed;
  const t = Date.UTC(
    d.getUTCFullYear(),
    d.getUTCMonth(),
    d.getUTCDate(),
    d.getUTCHours(),
    d.getUTCMinutes(),
    0,
    0,
  );
  return new Date(t).toISOString();
}

export async function slotCapacity(
  admin: SupabaseClient,
  prestataireId: string,
  at: Date,
): Promise<number> {
  const pgDow = at.getDay();
  const hh = String(at.getHours()).padStart(2, "0");
  const mm = String(at.getMinutes()).padStart(2, "0");
  const timeText = `${hh}:${mm}:00`;

  const { data: override } = await admin
    .from("disponibilite_capacity_overrides")
    .select("capacite_simultanee")
    .eq("prestataire_id", prestataireId)
    .eq("jour_semaine", pgDow)
    .lte("heure_debut", timeText)
    .gt("heure_fin", timeText)
    .limit(1)
    .maybeSingle();

  const overrideCapacity = (override?.capacite_simultanee as number | undefined);
  if (overrideCapacity != null && overrideCapacity > 0) return overrideCapacity;

  const { data: rule } = await admin
    .from("disponibilites")
    .select("capacite_simultanee")
    .eq("prestataire_id", prestataireId)
    .eq("jour_semaine", pgDow)
    .lte("heure_debut", timeText)
    .gt("heure_fin", timeText)
    .limit(1)
    .maybeSingle();

  return (rule?.capacite_simultanee as number | undefined) ?? 1;
}

export async function activeReservationsAtSlot(
  admin: SupabaseClient,
  prestataireId: string,
  at: Date,
): Promise<number> {
  const start = startOfMinuteLocal(at.toISOString());
  const end = new Date(start.getTime() + 60_000);
  const { data } = await admin
    .from("reservations")
    .select("id, statut")
    .eq("prestataire_id", prestataireId)
    .gte("date_heure", start.toISOString())
    .lt("date_heure", end.toISOString());

  let count = 0;
  for (const row of data ?? []) {
    const statut = String(row.statut ?? "").trim().toLowerCase().replaceAll("é", "e");
    if (["en_attente", "pending", "confirmee", "confirmed"].includes(statut)) {
      count += 1;
    }
  }
  return count;
}

function connectRedirectFunctionBase(): string {
  const explicit = Deno.env.get("STRIPE_CONNECT_REDIRECT_BASE_URL")?.trim();
  if (explicit) return explicit.replace(/\/$/, "");
  const supabaseUrl = Deno.env.get("SUPABASE_URL")?.trim();
  if (supabaseUrl) {
    return `${supabaseUrl.replace(/\/$/, "")}/functions/v1/stripe_connect_redirect`;
  }
  throw new Error(
    "SUPABASE_URL ou STRIPE_CONNECT_REDIRECT_BASE_URL requis pour les URLs de retour",
  );
}

export function clientPaymentReturnUrl(): string {
  const fromEnv = Deno.env.get("STRIPE_CLIENT_PAYMENT_RETURN_URL")?.trim();
  if (fromEnv) return fromEnv;
  return `${connectRedirectFunctionBase()}?to=client_payment_return`;
}

export type ClientProfileRow = {
  id: string;
  stripe_customer_id?: string | null;
};

/** Rôle client + ligne profil (création si manquante). */
export async function ensureClientProfileRow(
  admin: SupabaseClient,
  userId: string,
): Promise<ClientProfileRow> {
  const { data: roles } = await admin
    .from("user_roles")
    .select("role")
    .eq("user_id", userId);

  const hasClient = (roles ?? []).some((r) =>
    String((r as { role?: string }).role) === "client"
  );
  if (!hasClient) {
    const { error: roleErr } = await admin.from("user_roles").insert({
      user_id: userId,
      role: "client",
    });
    if (roleErr && roleErr.code !== "23505") throw roleErr;
  }

  const { data: existing } = await admin
    .from("client_profiles")
    .select("id, stripe_customer_id")
    .eq("user_id", userId)
    .maybeSingle();

  if (existing?.id) {
    return existing as ClientProfileRow;
  }

  const { data: inserted, error } = await admin
    .from("client_profiles")
    .insert({ user_id: userId })
    .select("id, stripe_customer_id")
    .single();

  if (error) throw error;
  return inserted as ClientProfileRow;
}

export async function ensureStripeCustomer(
  admin: SupabaseClient,
  stripe: Stripe,
  clientProfileId: string,
  userId: string,
  email?: string | null,
): Promise<string> {
  const { data: profile } = await admin
    .from("client_profiles")
    .select("stripe_customer_id")
    .eq("id", clientProfileId)
    .maybeSingle();

  const existing = profile?.stripe_customer_id as string | undefined;
  if (existing) return existing;

  const customer = await stripe.customers.create({
    email: email ?? undefined,
    metadata: { supabase_user_id: userId, client_profile_id: clientProfileId },
  });

  await admin
    .from("client_profiles")
    .update({ stripe_customer_id: customer.id })
    .eq("id", clientProfileId);

  return customer.id;
}
