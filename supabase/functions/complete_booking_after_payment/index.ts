import { corsHeaders, jsonResponse } from "../_shared/cors.ts";
import { ensureReservationForPaymentIntent } from "../_shared/stripe_reservation.ts";
import {
  normalizeBookingInstant,
  requireAuthUser,
  serviceClient,
  stripeClient,
} from "../_shared/stripe_booking.ts";
import type Stripe from "npm:stripe@17.7.0";

interface Body {
  paymentIntentId?: string;
  prestataireId?: string;
  serviceId?: string;
  packId?: string;
  dateHeure?: string;
  notesClient?: string;
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
    const paymentIntentId = String(body.paymentIntentId ?? "").trim();
    const prestataireId = String(body.prestataireId ?? "").trim();
    const serviceId = String(body.serviceId ?? "").trim();
    const packId = String(body.packId ?? "").trim();
    const dateHeure = String(body.dateHeure ?? "").trim();
    const notesClient = body.notesClient?.trim();

    if (!paymentIntentId || !prestataireId || !dateHeure) {
      return jsonResponse({ error: "Paramètres invalides" }, 400);
    }
    if (!packId && !serviceId) {
      return jsonResponse({ error: "Paramètres invalides" }, 400);
    }

    const admin = serviceClient();
    const stripe = stripeClient();

    let pi = await stripe.paymentIntents.retrieve(paymentIntentId);
    const isPayable = (intent: Stripe.PaymentIntent) =>
      intent.status === "requires_capture" ||
      intent.status === "succeeded" ||
      intent.status === "processing";

    if (!isPayable(pi)) {
      for (let attempt = 0; attempt < 5; attempt++) {
        await new Promise((r) => setTimeout(r, 400 * (attempt + 1)));
        pi = await stripe.paymentIntents.retrieve(paymentIntentId);
        if (isPayable(pi)) break;
      }
    }

    if (!isPayable(pi)) {
      return jsonResponse({
        error: "Paiement non confirmé",
        code: "payment_not_ready",
        status: pi.status,
      }, 402);
    }

    const meta = pi.metadata ?? {};
    const normalizedRequestDate = normalizeBookingInstant(dateHeure);
    const normalizedMetaDate = normalizeBookingInstant(
      String(meta.date_heure ?? ""),
    );
    const metaPackId = String(meta.pack_id ?? "").trim();
    const metaServiceId = String(meta.service_id ?? "").trim();
    const packOk = packId
      ? metaPackId === packId
      : metaPackId.length === 0;
    const serviceOk = packId
      ? true
      : metaServiceId === serviceId;
    if (
      meta.supabase_user_id !== user.id ||
      meta.prestataire_id !== prestataireId ||
      !packOk ||
      !serviceOk ||
      normalizedMetaDate !== normalizedRequestDate
    ) {
      return jsonResponse({ error: "Métadonnées de paiement invalides" }, 400);
    }

    const result = await ensureReservationForPaymentIntent(admin, pi);
    if (!result.reservationId) {
      const { data: byPi } = await admin
        .from("reservations")
        .select()
        .eq("stripe_payment_intent_id", paymentIntentId)
        .maybeSingle();
      if (byPi) {
        return jsonResponse({ reservation: byPi, alreadyCreated: true });
      }
      return jsonResponse({ error: "Créneau indisponible", code: "slot_taken" }, 409);
    }

    if (notesClient) {
      await admin
        .from("reservations")
        .update({ notes_client: notesClient })
        .eq("id", result.reservationId);
    }

    await stripe.paymentIntents.update(paymentIntentId, {
      metadata: { ...meta, reservation_id: result.reservationId },
    });

    const { data: reservation } = await admin
      .from("reservations")
      .select()
      .eq("id", result.reservationId)
      .single();

    return jsonResponse({
      reservation,
      alreadyCreated: !result.created,
    });
  } catch (e) {
    if (e instanceof Response) return e;
    console.error(e);
    return jsonResponse({ error: String(e) }, 500);
  }
});
