import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  clientPaymentReturnUrl,
  ensureStripeCustomer,
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

    const { data: clientRow } = await admin
      .from("client_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (!clientRow?.id) {
      return jsonResponse({ error: "Profil client manquant" }, 403);
    }
    const clientProfileId = clientRow.id as string;

    const customerId = await ensureStripeCustomer(
      admin,
      stripe,
      clientProfileId,
      user.id,
      user.email,
    );

    const portal = await stripe.billingPortal.sessions.create({
      customer: customerId,
      return_url: clientPaymentReturnUrl(),
    });

    return jsonResponse({ url: portal.url });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
