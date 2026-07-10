import type Stripe from "npm:stripe@17.7.0";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export type SubscriptionTier = "solo" | "multi";
export type SubscriptionInterval = "month" | "year";

/** Jours d’essai catalogue (plateforme) — repli si réglage DB indisponible. */
export const PRESTATAIRE_TRIAL_DAYS_FALLBACK = 90;

export async function getCatalogTrialDays(
  admin: SupabaseClient,
): Promise<number> {
  const { data, error } = await admin.rpc("get_catalog_trial_days");
  if (error) {
    console.warn("get_catalog_trial_days:", error.message);
    return PRESTATAIRE_TRIAL_DAYS_FALLBACK;
  }
  const days = typeof data === "number" ? data : Number(data);
  if (Number.isFinite(days) && days > 0 && days <= 730) return days;
  return PRESTATAIRE_TRIAL_DAYS_FALLBACK;
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

export function subscriptionSuccessUrl(): string {
  const fromEnv = Deno.env.get("STRIPE_SUBSCRIPTION_SUCCESS_URL")?.trim();
  if (fromEnv) return fromEnv;
  return `${connectRedirectFunctionBase()}?to=subscription_success`;
}

export function subscriptionCancelUrl(): string {
  const fromEnv = Deno.env.get("STRIPE_SUBSCRIPTION_CANCEL_URL")?.trim();
  if (fromEnv) return fromEnv;
  return `${connectRedirectFunctionBase()}?to=subscription_cancel`;
}

export function subscriptionPriceId(
  tier: SubscriptionTier,
  interval: SubscriptionInterval,
): string {
  const key = interval === "month"
    ? (tier === "solo" ? "STRIPE_PRICE_SOLO_MONTHLY" : "STRIPE_PRICE_MULTI_MONTHLY")
    : (tier === "solo" ? "STRIPE_PRICE_SOLO_YEARLY" : "STRIPE_PRICE_MULTI_YEARLY");
  const priceId = Deno.env.get(key)?.trim();
  if (!priceId?.startsWith("price_")) {
    throw new Error(`${key} manquant ou invalide (attendu price_...)`);
  }
  return priceId;
}

export function tierForServiceCount(serviceCount: number): SubscriptionTier {
  return serviceCount >= 2 ? "multi" : "solo";
}

export type PrestataireBillingProfileRow = {
  id: string;
  stripe_billing_customer_id?: string | null;
  stripe_subscription_id?: string | null;
  subscription_status?: string | null;
};

/** Statuts où l’essai Stripe a déjà été consommé ou l’abonnement est en cours. */
const STRIPE_SUBSCRIPTION_TRIAL_EXHAUSTED_STATUSES = new Set([
  "active",
  "trialing",
  "past_due",
  "canceled",
  "unpaid",
]);

/**
 * Premier abonnement (ou reprise après checkout abandonné) → essai plateforme.
 * Ne pas se baser sur stripe_subscription_id : un checkout incomplet peut déjà
 * avoir créé un sub_... sans essai explicite, et Stripe retombe alors sur l’essai
 * du prix (ex. 5 jours au lieu des 90 jours catalogue).
 */
export function qualifiesForStripeSubscriptionTrial(
  prestataire: PrestataireBillingProfileRow,
): boolean {
  const status = String(prestataire.subscription_status ?? "none");
  return !STRIPE_SUBSCRIPTION_TRIAL_EXHAUSTED_STATUSES.has(status);
}

/** Rôle prestataire + ligne profil (création si manquante, ex. hub sans sauvegarde). */
export async function ensurePrestataireProfileRow(
  admin: SupabaseClient,
  userId: string,
): Promise<PrestataireBillingProfileRow> {
  const { data: roles } = await admin
    .from("user_roles")
    .select("role")
    .eq("user_id", userId);

  const hasPresta = (roles ?? []).some((r) =>
    String((r as { role?: string }).role) === "prestataire"
  );
  if (!hasPresta) {
    const { error: roleErr } = await admin.from("user_roles").insert({
      user_id: userId,
      role: "prestataire",
    });
    if (roleErr && roleErr.code !== "23505") throw roleErr;
  }

  const { data: existing } = await admin
    .from("prestataire_profiles")
    .select(
      "id, stripe_billing_customer_id, stripe_subscription_id, subscription_status",
    )
    .eq("user_id", userId)
    .maybeSingle();

  if (existing?.id) {
    return existing as PrestataireBillingProfileRow;
  }

  const { data: inserted, error } = await admin
    .from("prestataire_profiles")
    .insert({ user_id: userId })
    .select(
      "id, stripe_billing_customer_id, stripe_subscription_id, subscription_status",
    )
    .single();

  if (error) throw error;
  return inserted as PrestataireBillingProfileRow;
}

export function mapStripeSubscriptionStatus(
  status: Stripe.Subscription.Status,
): string {
  switch (status) {
    case "active":
    case "trialing":
    case "past_due":
    case "canceled":
    case "incomplete":
    case "unpaid":
    case "incomplete_expired":
    case "paused":
      return status;
    default:
      return "none";
  }
}

export function tierFromPriceId(priceId: string): SubscriptionTier | null {
  const soloMonth = Deno.env.get("STRIPE_PRICE_SOLO_MONTHLY")?.trim();
  const soloYear = Deno.env.get("STRIPE_PRICE_SOLO_YEARLY")?.trim();
  if (priceId === soloMonth || priceId === soloYear) return "solo";
  const multiMonth = Deno.env.get("STRIPE_PRICE_MULTI_MONTHLY")?.trim();
  const multiYear = Deno.env.get("STRIPE_PRICE_MULTI_YEARLY")?.trim();
  if (priceId === multiMonth || priceId === multiYear) return "multi";
  return null;
}

export function intervalFromPriceId(priceId: string): SubscriptionInterval | null {
  const monthly = [
    Deno.env.get("STRIPE_PRICE_SOLO_MONTHLY")?.trim(),
    Deno.env.get("STRIPE_PRICE_MULTI_MONTHLY")?.trim(),
  ];
  if (monthly.includes(priceId)) return "month";
  const yearly = [
    Deno.env.get("STRIPE_PRICE_SOLO_YEARLY")?.trim(),
    Deno.env.get("STRIPE_PRICE_MULTI_YEARLY")?.trim(),
  ];
  if (yearly.includes(priceId)) return "year";
  return null;
}

export async function ensurePrestataireBillingCustomer(
  admin: SupabaseClient,
  stripe: Stripe,
  prestataireId: string,
  userId: string,
  email?: string | null,
  existingCustomerId?: string | null,
): Promise<string> {
  if (existingCustomerId?.startsWith("cus_")) return existingCustomerId;

  const customer = await stripe.customers.create({
    email: email ?? undefined,
    metadata: {
      prestataire_id: prestataireId,
      supabase_user_id: userId,
    },
  });

  await admin
    .from("prestataire_profiles")
    .update({ stripe_billing_customer_id: customer.id })
    .eq("id", prestataireId);

  return customer.id;
}

export async function syncPrestataireSubscriptionRow(
  admin: SupabaseClient,
  prestataireId: string,
  subscription: Stripe.Subscription,
): Promise<void> {
  const item = subscription.items.data[0];
  const priceId = typeof item?.price === "string"
    ? item.price
    : item?.price?.id;
  const tier = priceId ? tierFromPriceId(priceId) : null;
  const interval = priceId ? intervalFromPriceId(priceId) : null;
  const status = mapStripeSubscriptionStatus(subscription.status);
  const periodEnd = subscription.current_period_end
    ? new Date(subscription.current_period_end * 1000).toISOString()
    : null;

  await admin
    .from("prestataire_profiles")
    .update({
      stripe_subscription_id: subscription.id,
      subscription_status: status,
      subscription_tier: tier,
      subscription_interval: interval,
      subscription_current_period_end: periodEnd,
      subscription_updated_at: new Date().toISOString(),
      stripe_billing_customer_id: typeof subscription.customer === "string"
        ? subscription.customer
        : subscription.customer?.id,
    })
    .eq("id", prestataireId);
}

export async function findPrestataireIdForSubscription(
  admin: SupabaseClient,
  subscription: Stripe.Subscription,
): Promise<string | null> {
  const metaId = subscription.metadata?.prestataire_id;
  if (metaId) return metaId;

  const customerId = typeof subscription.customer === "string"
    ? subscription.customer
    : subscription.customer?.id;
  if (!customerId) return null;

  const { data } = await admin
    .from("prestataire_profiles")
    .select("id")
    .eq("stripe_billing_customer_id", customerId)
    .maybeSingle();

  return (data?.id as string | undefined) ?? null;
}
