import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
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
  amountCents?: number;
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
    const amountCents = Number(body.amountCents);

    if (!prestataireId || !serviceId || !dateHeureRaw || !Number.isFinite(amountCents)) {
      return jsonResponse({ error: "Paramètres invalides" }, 400);
    }
    if (amountCents < 50) {
      return jsonResponse({ error: "Montant trop faible" }, 400);
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

    const expectedCents = Math.round(Number(service.prix) * 100);
    if (expectedCents !== amountCents) {
      return jsonResponse({ error: "Montant incorrect pour ce service" }, 400);
    }

    const { data: prestataire } = await admin
      .from("prestataire_profiles")
      .select("stripe_connect_account_id, nom_salon")
      .eq("id", prestataireId)
      .maybeSingle();
    const connectAccountId = prestataire?.stripe_connect_account_id as string | undefined;
    if (!connectAccountId?.startsWith("acct_")) {
      return jsonResponse({
        error: "Ce prestataire n'accepte pas encore les paiements en ligne",
        code: "prestataire_not_payable",
      }, 400);
    }

    const connectAccount = await stripe.accounts.retrieve(connectAccountId);
    if (!accountCanAcceptPayments(connectAccount)) {
      return jsonResponse({
        error: "Le compte paiement du prestataire n'est pas encore activé",
        code: "prestataire_not_payable",
      }, 400);
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

    const feePercent = Number(Deno.env.get("STRIPE_PLATFORM_FEE_PERCENT") ?? "10");
    const applicationFeeAmount = Math.max(
      0,
      Math.round(amountCents * (feePercent / 100)),
    );

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: "eur",
      customer: customerId,
      capture_method: "manual",
      automatic_payment_methods: { enabled: true },
      application_fee_amount: applicationFeeAmount,
      transfer_data: { destination: connectAccountId },
      metadata: {
        client_id: clientId,
        prestataire_id: prestataireId,
        service_id: serviceId,
        date_heure: dateHeure,
        supabase_user_id: user.id,
      },
    });

    if (!paymentIntent.client_secret) {
      return jsonResponse({ error: "Impossible de créer le paiement" }, 500);
    }

    return jsonResponse({
      paymentIntentId: paymentIntent.id,
      paymentIntentClientSecret: paymentIntent.client_secret,
      customerId,
      ephemeralKey: ephemeralKey.secret,
      amountCents,
      currency: "eur",
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
