import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  clientPaymentReturnUrl,
  ensureClientProfileRow,
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

    const clientRow = await ensureClientProfileRow(admin, user.id);
    const clientProfileId = clientRow.id;

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
