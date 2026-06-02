import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  type BookingPaymentMode,
  computeBookingPricing,
  countClientBookingsForPlatformFee,
} from "../_shared/booking_pricing.ts";
import { fetchActiveReferralDiscount } from "../_shared/referral_discount.ts";
import { accountCanAcceptPayments } from "../_shared/stripe_connect.ts";
import {
  activeReservationsAtSlot,
  ensureStripeCustomer,
  normalizeBookingInstant,
  requireAuthUser,
  serviceClient,
  slotCapacity,
  stripeClient,
} from "../_shared/stripe_booking.ts";

interface Body {
  prestataireId?: string;
  serviceId?: string;
  dateHeure?: string;
  paymentMode?: string;
  /** Déprécié : le montant est recalculé côté serveur. */
  amountCents?: number;
}

function parsePaymentMode(raw: string): BookingPaymentMode | null {
  if (raw === "deposit_20" || raw === "on_site") return raw;
  return null;
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
    const body = (await req.json()) as Body;
    const prestataireId = String(body.prestataireId ?? "").trim();
    const serviceId = String(body.serviceId ?? "").trim();
    const dateHeureRaw = String(body.dateHeure ?? "").trim();
    const dateHeure = normalizeBookingInstant(dateHeureRaw);
    const paymentMode = parsePaymentMode(String(body.paymentMode ?? "").trim());

    if (!prestataireId || !serviceId || !dateHeureRaw || !paymentMode) {
      return jsonResponse({ error: "Paramètres invalides" }, 400);
    }

    const admin = serviceClient();
    const stripe = stripeClient();

    const { data: clientRow } = await admin
      .from("client_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (!clientRow?.id) {
      return jsonResponse({ error: "Profil client manquant" }, 403);
    }
    const clientId = clientRow.id as string;

    const { data: ownPresta } = await admin
      .from("prestataire_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (ownPresta?.id === prestataireId) {
      return jsonResponse({ error: "Réservation sur son propre profil interdite" }, 403);
    }

    const { data: service } = await admin
      .from("services_beaute")
      .select("id, prix, prestataire_id, nom")
      .eq("id", serviceId)
      .maybeSingle();
    if (!service || service.prestataire_id !== prestataireId) {
      return jsonResponse({ error: "Service introuvable" }, 404);
    }

    const originalServicePriceCents = Math.round(Number(service.prix) * 100);
    const referralDiscount = await fetchActiveReferralDiscount(admin, clientId);

    const { data: prestataire } = await admin
      .from("prestataire_profiles")
      .select(
        "stripe_connect_account_id, stripe_connect_charges_enabled, nom_salon",
      )
      .eq("id", prestataireId)
      .maybeSingle();

    const connectAccountId = prestataire?.stripe_connect_account_id as
      | string
      | undefined;
    const chargesEnabled = prestataire?.stripe_connect_charges_enabled === true;
    const prestataireAcceptsConnect = Boolean(
      connectAccountId?.startsWith("acct_") && chargesEnabled,
    );

    let connectReady = false;
    if (prestataireAcceptsConnect && connectAccountId) {
      const connectAccount = await stripe.accounts.retrieve(connectAccountId);
      connectReady = accountCanAcceptPayments(connectAccount);
    }

    const priorBookingCount = await countClientBookingsForPlatformFee(
      admin,
      clientId,
    );

    let pricing;
    try {
      pricing = computeBookingPricing({
        servicePriceCents: originalServicePriceCents,
        paymentMode,
        priorBookingCount,
        prestataireAcceptsConnect: connectReady,
        referralDiscountPercent: referralDiscount?.percent,
      });
    } catch (e) {
      if (String(e).includes("deposit_requires_connect")) {
        return jsonResponse({
          error: "Acompte indisponible pour ce prestataire",
          code: "deposit_requires_connect",
        }, 400);
      }
      throw e;
    }

    if (!pricing.requiresInAppPayment) {
      return jsonResponse({
        error: "Aucun paiement requis dans l'application",
        code: "no_payment_required",
      }, 400);
    }

    if (pricing.totalChargeCents < 50) {
      return jsonResponse({ error: "Montant trop faible" }, 400);
    }

    const slotAt = new Date(dateHeure);
    const capacity = await slotCapacity(admin, prestataireId, slotAt);
    const booked = await activeReservationsAtSlot(admin, prestataireId, slotAt);
    if (booked >= capacity) {
      return jsonResponse({ error: "Créneau indisponible", code: "slot_taken" }, 409);
    }

    const customerId = await ensureStripeCustomer(
      admin,
      stripe,
      clientId,
      user.id,
      user.email,
    );

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: "2024-11-20.acacia" },
    );

    const platformFee = pricing.platformFeeCents;
    const prestatairePortion = pricing.prestatairePortionCents;
    const useConnect = prestatairePortion > 0 && connectReady && connectAccountId;

    if (paymentMode === "deposit_20" && !useConnect) {
      return jsonResponse({
        error: "Ce prestataire n'accepte pas encore les paiements en ligne",
        code: "prestataire_not_payable",
      }, 400);
    }

    const metadata: Record<string, string> = {
      client_id: clientId,
      prestataire_id: prestataireId,
      service_id: serviceId,
      date_heure: dateHeure,
      supabase_user_id: user.id,
      payment_mode: paymentMode,
      platform_fee_cents: String(platformFee),
      service_price_cents: String(pricing.servicePriceCents),
      prestataire_amount_cents: String(prestatairePortion),
    };
    if (pricing.referralDiscountPercent != null && pricing.referralDiscountPercent > 0) {
      metadata.original_service_price_cents = String(
        pricing.originalServicePriceCents ?? originalServicePriceCents,
      );
      metadata.referral_discount_percent = String(pricing.referralDiscountPercent);
    }

    const piParams: Parameters<typeof stripe.paymentIntents.create>[0] = {
      amount: pricing.totalChargeCents,
      currency: "eur",
      customer: customerId,
      capture_method: "manual",
      automatic_payment_methods: { enabled: true },
      metadata,
    };

    if (useConnect) {
      piParams.application_fee_amount = platformFee;
      piParams.transfer_data = { destination: connectAccountId! };
    }

    const paymentIntent = await stripe.paymentIntents.create(piParams);

    if (!paymentIntent.client_secret) {
      return jsonResponse({ error: "Impossible de créer le paiement" }, 500);
    }

    return jsonResponse({
      paymentIntentId: paymentIntent.id,
      paymentIntentClientSecret: paymentIntent.client_secret,
      customerId,
      ephemeralKey: ephemeralKey.secret,
      amountCents: pricing.totalChargeCents,
      currency: "eur",
      pricing,
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
