import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  accountCanAcceptPayments,
  mapOnboardingStatus,
  syncPrestataireConnectAccount,
} from "../_shared/stripe_connect.ts";
import {
  requireAuthUser,
  serviceClient,
  stripeClient,
} from "../_shared/stripe_booking.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST" && req.method !== "GET") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }

  try {
    const { user } = await requireAuthUser(req);
    const admin = serviceClient();
    const stripe = stripeClient();

    const { data: prestataire } = await admin
      .from("prestataire_profiles")
      .select(
        "id, stripe_connect_account_id, stripe_connect_onboarding_status, "
          + "stripe_connect_charges_enabled, stripe_connect_payouts_enabled, "
          + "stripe_connect_details_submitted",
      )
      .eq("user_id", user.id)
      .maybeSingle();

    if (!prestataire?.id) {
      return jsonResponse({ error: "Profil prestataire introuvable" }, 404);
    }

    const accountId = prestataire.stripe_connect_account_id as string | undefined;
    if (!accountId) {
      return jsonResponse({
        accountId: null,
        onboardingStatus: "not_started",
        chargesEnabled: false,
        payoutsEnabled: false,
        detailsSubmitted: false,
        canAcceptPayments: false,
      });
    }

    const account = await stripe.accounts.retrieve(accountId);
    await syncPrestataireConnectAccount(
      admin,
      prestataire.id as string,
      account,
    );

    return jsonResponse({
      accountId: account.id,
      onboardingStatus: mapOnboardingStatus(account),
      chargesEnabled: account.charges_enabled ?? false,
      payoutsEnabled: account.payouts_enabled ?? false,
      detailsSubmitted: account.details_submitted ?? false,
      canAcceptPayments: accountCanAcceptPayments(account),
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
