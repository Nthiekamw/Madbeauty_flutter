import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  accountCanAcceptPayments,
  connectRefreshUrl,
  connectReturnUrl,
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
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }

  try {
    const { user } = await requireAuthUser(req);
    const admin = serviceClient();
    const stripe = stripeClient();

    const { data: prestataire } = await admin
      .from("prestataire_profiles")
      .select(
        "id, nom_salon, stripe_connect_account_id, stripe_connect_charges_enabled",
      )
      .eq("user_id", user.id)
      .maybeSingle();

    if (!prestataire?.id) {
      return jsonResponse({ error: "Profil prestataire introuvable" }, 404);
    }

    const prestataireId = prestataire.id as string;
    let accountId = prestataire.stripe_connect_account_id as string | undefined;

    if (!accountId) {
      const account = await stripe.accounts.create({
        type: "express",
        country: "FR",
        email: user.email ?? undefined,
        business_type: "individual",
        capabilities: {
          card_payments: { requested: true },
          transfers: { requested: true },
        },
        metadata: {
          prestataire_id: prestataireId,
          supabase_user_id: user.id,
        },
      });
      accountId = account.id;
      await syncPrestataireConnectAccount(admin, prestataireId, account);
    } else {
      const account = await stripe.accounts.retrieve(accountId);
      await syncPrestataireConnectAccount(admin, prestataireId, account);
      if (accountCanAcceptPayments(account)) {
        return jsonResponse({
          alreadyComplete: true,
          accountId,
          chargesEnabled: true,
          payoutsEnabled: account.payouts_enabled ?? false,
        });
      }
    }

    const link = await stripe.accountLinks.create({
      account: accountId,
      refresh_url: connectRefreshUrl(),
      return_url: connectReturnUrl(),
      type: "account_onboarding",
    });

    return jsonResponse({
      url: link.url,
      accountId,
      expiresAt: link.expires_at,
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
