import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  createServiceClient,
  fetchFcmTokenForPrestataireProfileId,
  sendFcmNotification,
} from "../_shared/booking_notify.ts";
import {
  requireAuthUser,
  serviceClient,
} from "../_shared/stripe_booking.ts";

const ACTIVE = new Set(["active", "trialing"]);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method Not Allowed" }, 405);
  }

  try {
    const { user } = await requireAuthUser(req);
    const supabase = serviceClient();

    const { data: presta, error } = await supabase
      .from("prestataire_profiles")
      .select(
        "id, nom_salon, nom_affiche, subscription_status, catalog_trial_ends_at, ville, nom_affiche",
      )
      .eq("user_id", user.id)
      .maybeSingle();

    if (error) throw error;
    if (!presta?.id) {
      return jsonResponse({ ok: true, skipped: true, reason: "no_prestataire" });
    }

    const status = String(presta.subscription_status ?? "none");
    if (ACTIVE.has(status)) {
      return jsonResponse({ ok: true, skipped: true, reason: "already_active" });
    }

    const trialEnds = presta.catalog_trial_ends_at as string | null | undefined;
    if (trialEnds && new Date(trialEnds).getTime() > Date.now()) {
      return jsonResponse({ ok: true, skipped: true, reason: "catalog_trial" });
    }

    const salon = String(presta.nom_affiche ?? presta.nom_salon ?? "").trim();
    const ville = String(presta.ville ?? "").trim();
    if (salon.isEmpty || ville.isEmpty) {
      return jsonResponse({ ok: true, skipped: true, reason: "profile_incomplete" });
    }

    const notifyClient = createServiceClient();
    const token = await fetchFcmTokenForPrestataireProfileId(
      notifyClient,
      String(presta.id),
    );
    if (!token) {
      return jsonResponse({ ok: true, skipped: true, reason: "no_fcm_token" });
    }

    await sendFcmNotification({
      token,
      title: "MadBeauty Pro",
      body:
        "Ton profil n’est pas visible par les clientes. Active ton abonnement pour apparaître dans le catalogue.",
      data: {
        type: "prestataire_catalog_visibility",
        prestataire_id: String(presta.id),
      },
    });

    return jsonResponse({ ok: true, sent: true });
  } catch (e) {
    console.error(e);
    return jsonResponse({ ok: false, error: String(e) }, 500);
  }
});
