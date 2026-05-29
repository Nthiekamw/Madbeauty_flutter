import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import {
  requireAuthUser,
  serviceClient,
  stripeClient,
} from "../_shared/stripe_booking.ts";

interface Body {
  reservationId?: string;
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
    const reservationId = String(body.reservationId ?? "").trim();
    if (!reservationId) {
      return jsonResponse({ error: "reservationId requis" }, 400);
    }

    const admin = serviceClient();
    const stripe = stripeClient();

    const { data: prestataire } = await admin
      .from("prestataire_profiles")
      .select("id")
      .eq("user_id", user.id)
      .maybeSingle();
    if (!prestataire?.id) {
      return jsonResponse({ error: "Profil prestataire requis" }, 403);
    }

    const { data: reservation } = await admin
      .from("reservations")
      .select(
        "id, prestataire_id, statut, stripe_payment_intent_id, payment_status",
      )
      .eq("id", reservationId)
      .maybeSingle();

    if (!reservation) {
      return jsonResponse({ error: "Réservation introuvable" }, 404);
    }
    if (reservation.prestataire_id !== prestataire.id) {
      return jsonResponse({ error: "Accès refusé" }, 403);
    }

    const piId = reservation.stripe_payment_intent_id as string | undefined;
    if (!piId) {
      return jsonResponse({ ok: true, skipped: true, reason: "no_payment" });
    }
    if (reservation.payment_status === "captured") {
      return jsonResponse({ ok: true, skipped: true, reason: "already_captured" });
    }

    const pi = await stripe.paymentIntents.retrieve(piId);
    if (pi.status === "succeeded") {
      await admin
        .from("reservations")
        .update({ payment_status: "captured" })
        .eq("id", reservationId);
      return jsonResponse({ ok: true, status: "succeeded" });
    }

    if (pi.status !== "requires_capture") {
      return jsonResponse({
        error: "Paiement non capturable",
        status: pi.status,
      }, 400);
    }

    const captured = await stripe.paymentIntents.capture(piId);
    await admin
      .from("reservations")
      .update({ payment_status: "captured" })
      .eq("id", reservationId);

    return jsonResponse({ ok: true, status: captured.status });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
