import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  ensurePrestataireBillingCustomer,
  ensurePrestataireProfileRow,
  PRESTATAIRE_TRIAL_DAYS,
  subscriptionCancelUrl,
  subscriptionPriceId,
  subscriptionSuccessUrl,
  tierForServiceCount,
  type SubscriptionInterval,
  type SubscriptionTier,
} from "../_shared/prestataire_subscription.ts";
import {
  requireAuthUser,
  serviceClient,
  stripeClient,
} from "../_shared/stripe_booking.ts";

interface Body {
  tier?: string;
  interval?: string;
}

function parseTier(raw: string, serviceCount: number): SubscriptionTier {
  const t = raw.trim().toLowerCase();
  if (t === "solo" || t === "multi") return t;
  return tierForServiceCount(serviceCount);
}

function parseInterval(raw: string): SubscriptionInterval | null {
  if (raw === "month" || raw === "year") return raw;
  return null;
}

const ACTIVE_STATUSES = new Set(["active", "trialing", "past_due"]);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }

  try {
    const { user } = await requireAuthUser(req);
    const body = (await req.json()) as Body;
    const interval = parseInterval(String(body.interval ?? "").trim());
    if (!interval) {
      return jsonResponse({ error: "interval invalide (month|year)" }, 400);
    }

    const admin = serviceClient();
    const stripe = stripeClient();

    const prestataire = await ensurePrestataireProfileRow(admin, user.id);
    const prestataireId = prestataire.id;
    const currentStatus = String(prestataire.subscription_status ?? "none");
    if (ACTIVE_STATUSES.has(currentStatus)) {
      return jsonResponse({
        code: "subscription_already_active",
        error: "Un abonnement est déjà actif. Utilise le portail de facturation.",
      }, 409);
    }

    const { count } = await admin
      .from("services_beaute")
      .select("id", { count: "exact", head: true })
      .eq("prestataire_id", prestataireId);

    const serviceCount = count ?? 0;
    const tier = parseTier(String(body.tier ?? ""), serviceCount);
    const expectedTier = tierForServiceCount(serviceCount);
    if (tier !== expectedTier) {
      return jsonResponse({
        code: "tier_mismatch",
        error: `Palier attendu : ${expectedTier} (${serviceCount} service(s)).`,
        expectedTier,
        serviceCount,
      }, 400);
    }

    let priceId: string;
    try {
      priceId = subscriptionPriceId(tier, interval);
    } catch (e) {
      return jsonResponse({ error: String(e), code: "stripe_not_configured" }, 503);
    }

    const customerId = await ensurePrestataireBillingCustomer(
      admin,
      stripe,
      prestataireId,
      user.id,
      user.email,
      prestataire.stripe_billing_customer_id as string | undefined,
    );

    const hadStripeSubscription = Boolean(
      prestataire.stripe_subscription_id?.trim(),
    );

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer: customerId,
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: subscriptionSuccessUrl(),
      cancel_url: subscriptionCancelUrl(),
      client_reference_id: prestataireId,
      subscription_data: {
        ...(hadStripeSubscription
          ? {}
          : { trial_period_days: PRESTATAIRE_TRIAL_DAYS }),
        metadata: {
          prestataire_id: prestataireId,
          supabase_user_id: user.id,
          tier,
          interval,
        },
      },
      metadata: {
        prestataire_id: prestataireId,
        tier,
        interval,
      },
    });

    if (!session.url) {
      return jsonResponse({ error: "URL Checkout manquante" }, 500);
    }

    return jsonResponse({
      url: session.url,
      sessionId: session.id,
      tier,
      interval,
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
