import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  findPrestataireIdForSubscription,
  syncPrestataireSubscriptionRow,
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
      .select("id, stripe_subscription_id")
      .eq("user_id", user.id)
      .maybeSingle();

    if (!prestataire?.id) {
      return jsonResponse({ error: "Profil prestataire introuvable" }, 404);
    }

    const prestataireId = prestataire.id as string;
    const subId = prestataire.stripe_subscription_id as string | undefined;

    if (!subId?.startsWith("sub_")) {
      const { data: row } = await admin
        .from("prestataire_profiles")
        .select(
          "subscription_status, subscription_tier, subscription_interval, subscription_current_period_end",
        )
        .eq("id", prestataireId)
        .single();
      return jsonResponse({ subscription: row, synced: false });
    }

    const subscription = await stripe.subscriptions.retrieve(subId);
    await syncPrestataireSubscriptionRow(admin, prestataireId, subscription);

    const resolvedId = await findPrestataireIdForSubscription(admin, subscription);
    if (resolvedId && resolvedId !== prestataireId) {
      console.warn("subscription prestataire_id mismatch", resolvedId, prestataireId);
    }

    const { data: row } = await admin
      .from("prestataire_profiles")
      .select(
        "subscription_status, subscription_tier, subscription_interval, subscription_current_period_end, stripe_subscription_id",
      )
      .eq("id", prestataireId)
      .single();

    return jsonResponse({ subscription: row, synced: true });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
