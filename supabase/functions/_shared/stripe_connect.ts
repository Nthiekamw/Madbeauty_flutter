import type Stripe from "npm:stripe@17.7.0";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

/** Stripe Account Links exigent http(s) — pas les deep links `com.app://`. */
function isValidStripeAccountLinkUrl(url: string): boolean {
  try {
    const u = new URL(url.trim());
    if (u.protocol === "https:") return true;
    if (u.protocol === "http:" && u.hostname === "localhost") return true;
    return false;
  } catch {
    return false;
  }
}

function connectRedirectFunctionBase(): string {
  const explicit = Deno.env.get("STRIPE_CONNECT_REDIRECT_BASE_URL")?.trim();
  if (explicit) {
    return explicit.replace(/\/$/, "");
  }
  const supabaseUrl = Deno.env.get("SUPABASE_URL")?.trim();
  if (supabaseUrl) {
    return `${supabaseUrl.replace(/\/$/, "")}/functions/v1/stripe_connect_redirect`;
  }
  throw new Error(
    "SUPABASE_URL ou STRIPE_CONNECT_REDIRECT_BASE_URL requis pour les URLs Connect",
  );
}

export function connectReturnUrl(): string {
  const fromEnv = Deno.env.get("STRIPE_CONNECT_RETURN_URL")?.trim();
  if (fromEnv && isValidStripeAccountLinkUrl(fromEnv)) return fromEnv;
  return `${connectRedirectFunctionBase()}?to=return`;
}

export function connectRefreshUrl(): string {
  const fromEnv = Deno.env.get("STRIPE_CONNECT_REFRESH_URL")?.trim();
  if (fromEnv && isValidStripeAccountLinkUrl(fromEnv)) return fromEnv;
  return `${connectRedirectFunctionBase()}?to=refresh`;
}

export function mapOnboardingStatus(account: Stripe.Account): string {
  if (account.charges_enabled && account.payouts_enabled) return "complete";
  if (account.requirements?.disabled_reason) return "restricted";
  if (account.details_submitted) return "pending";
  return "pending";
}

export async function syncPrestataireConnectAccount(
  admin: SupabaseClient,
  prestataireId: string,
  account: Stripe.Account,
): Promise<void> {
  await admin
    .from("prestataire_profiles")
    .update({
      stripe_connect_account_id: account.id,
      stripe_connect_onboarding_status: mapOnboardingStatus(account),
      stripe_connect_charges_enabled: account.charges_enabled ?? false,
      stripe_connect_payouts_enabled: account.payouts_enabled ?? false,
      stripe_connect_details_submitted: account.details_submitted ?? false,
      stripe_connect_updated_at: new Date().toISOString(),
    })
    .eq("id", prestataireId);
}

export async function syncPrestataireByAccountId(
  admin: SupabaseClient,
  account: Stripe.Account,
): Promise<void> {
  const prestataireId = account.metadata?.prestataire_id;
  if (prestataireId) {
    await syncPrestataireConnectAccount(admin, prestataireId, account);
    return;
  }

  const { data } = await admin
    .from("prestataire_profiles")
    .select("id")
    .eq("stripe_connect_account_id", account.id)
    .maybeSingle();

  if (data?.id) {
    await syncPrestataireConnectAccount(admin, data.id as string, account);
  }
}

export function accountCanAcceptPayments(account: Stripe.Account): boolean {
  return Boolean(
    account.charges_enabled &&
      account.details_submitted &&
      !account.requirements?.disabled_reason,
  );
}
