import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  ensurePrestataireBillingCustomer,
  subscriptionCancelUrl,
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

    const { data: prestataire } = await admin
      .from("prestataire_profiles")
      .select("id, stripe_billing_customer_id")
      .eq("user_id", user.id)
      .maybeSingle();

    if (!prestataire?.id) {
      return jsonResponse({ error: "Profil prestataire introuvable" }, 404);
    }

    const prestataireId = prestataire.id as string;
    const customerId = await ensurePrestataireBillingCustomer(
      admin,
      stripe,
      prestataireId,
      user.id,
      user.email,
      prestataire.stripe_billing_customer_id as string | undefined,
    );

    const portal = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: subscriptionCancelUrl(),
    });

    return jsonResponse({ url: portal.url });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
