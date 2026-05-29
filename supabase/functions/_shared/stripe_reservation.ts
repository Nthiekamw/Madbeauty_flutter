import type Stripe from "npm:stripe@17.7.0";
import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  activeReservationsAtSlot,
  normalizeBookingInstant,
  slotCapacity,
} from "./stripe_booking.ts";

export type PaymentStatusDb = "authorized" | "captured" | "failed" | "canceled";

export function paymentStatusFromIntent(pi: Stripe.PaymentIntent): PaymentStatusDb {
  if (pi.status === "succeeded") return "captured";
  if (pi.status === "canceled") return "canceled";
  if (pi.status === "requires_capture" || pi.status === "processing") {
    return "authorized";
  }
  return "failed";
}

/** Crée une réservation si le PaymentIntent est payé/autorisé et qu'aucune ligne n'existe. */
export async function ensureReservationForPaymentIntent(
  admin: SupabaseClient,
  pi: Stripe.PaymentIntent,
): Promise<{ created: boolean; reservationId?: string }> {
  const okStatus = pi.status === "requires_capture" ||
    pi.status === "succeeded" ||
    pi.status === "processing";
  if (!okStatus) {
    return { created: false };
  }

  const { data: existing } = await admin
    .from("reservations")
    .select("id")
    .eq("stripe_payment_intent_id", pi.id)
    .maybeSingle();

  if (existing?.id) {
    await admin
      .from("reservations")
      .update({
        payment_status: paymentStatusFromIntent(pi),
        amount_cents: pi.amount,
        currency: pi.currency ?? "eur",
      })
      .eq("id", existing.id);
    return { created: false, reservationId: existing.id as string };
  }

  const meta = pi.metadata ?? {};
  const clientId = meta.client_id as string | undefined;
  const prestataireId = meta.prestataire_id as string | undefined;
  const serviceId = meta.service_id as string | undefined;
  const dateHeure = meta.date_heure as string | undefined;

  if (!clientId || !prestataireId || !serviceId || !dateHeure) {
    return { created: false };
  }

  const slotAt = new Date(dateHeure);
  const dateHeureDb = normalizeBookingInstant(dateHeure);

  const capacity = await slotCapacity(admin, prestataireId, slotAt);
  const booked = await activeReservationsAtSlot(admin, prestataireId, slotAt);
  if (booked >= capacity) {
    return { created: false };
  }

  const { data: inserted, error } = await admin
    .from("reservations")
    .insert({
      client_id: clientId,
      prestataire_id: prestataireId,
      service_id: serviceId,
      date_heure: dateHeureDb,
      statut: "en_attente",
      amount_cents: pi.amount,
      currency: pi.currency ?? "eur",
      stripe_payment_intent_id: pi.id,
      payment_status: paymentStatusFromIntent(pi),
      paid_at: new Date().toISOString(),
    })
    .select("id")
    .single();

  if (error) {
    console.error("ensureReservationForPaymentIntent insert", error);
    return { created: false };
  }

  return { created: true, reservationId: inserted.id as string };
}

export async function updateReservationPaymentByIntentId(
  admin: SupabaseClient,
  paymentIntentId: string,
  paymentStatus: PaymentStatusDb,
): Promise<void> {
  await admin
    .from("reservations")
    .update({ payment_status: paymentStatus })
    .eq("stripe_payment_intent_id", paymentIntentId);
}
