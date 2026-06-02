import type Stripe from "npm:stripe@17.7.0";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export type SubscriptionTier = "solo" | "multi";
export type SubscriptionInterval = "month" | "year";

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
