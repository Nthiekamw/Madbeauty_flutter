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

    const customer = await stripe.customers.retrieve(customerId);
    let defaultPaymentMethodId: string | null = null;
    if (customer && typeof customer === "object" && !customer.deleted) {
      const defaultPm = customer.invoice_settings?.default_payment_method;
      defaultPaymentMethodId = typeof defaultPm === "string"
        ? defaultPm
        : defaultPm?.id ?? null;
    }

    const methods = await stripe.paymentMethods.list({
      customer: customerId,
      type: "card",
    });

    const paymentMethods = (methods.data ?? []).map((pm) => ({
      id: pm.id,
      brand: pm.card?.brand ?? "unknown",
      last4: pm.card?.last4 ?? "????",
      expMonth: pm.card?.exp_month ?? 0,
      expYear: pm.card?.exp_year ?? 0,
      isDefault: pm.id === defaultPaymentMethodId,
    }));

    return jsonResponse({ paymentMethods });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
