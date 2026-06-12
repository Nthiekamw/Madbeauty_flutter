import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  ensurePrestataireBillingCustomer,
  ensurePrestataireProfileRow,
} from "../_shared/prestataire_subscription.ts";
import {
  requireAuthUser,
  serviceClient,
  stripeClient,
} from "../_shared/stripe_booking.ts";

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
    const stripe = stripeClient();

    const prestataire = await ensurePrestataireProfileRow(admin, user.id);
    const customerId = await ensurePrestataireBillingCustomer(
      admin,
      stripe,
      prestataire.id,
      user.id,
      user.email,
      prestataire.stripe_billing_customer_id as string | undefined,
    );

    const setupIntent = await stripe.setupIntents.create({
      customer: customerId,
      automatic_payment_methods: { enabled: true },
      usage: "off_session",
    });

    if (!setupIntent.client_secret) {
      return jsonResponse({ error: "Impossible de préparer l’ajout de carte" }, 500);
    }

    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customerId },
      { apiVersion: "2024-11-20.acacia" },
    );

    return jsonResponse({
      customerId,
      ephemeralKey: ephemeralKey.secret,
      setupIntentClientSecret: setupIntent.client_secret,
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
