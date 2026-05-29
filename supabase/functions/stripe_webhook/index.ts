import Stripe from "npm:stripe@17.7.0";
import {
  sendFcmNotification,
} from "../_shared/booking_notify.ts";
import { syncPrestataireByAccountId } from "../_shared/stripe_connect.ts";
import {
  ensureReservationForPaymentIntent,
  updateReservationPaymentByIntentId,
} from "../_shared/stripe_reservation.ts";
import { serviceClient, stripeClient } from "../_shared/stripe_booking.ts";

async function notifyPrestatairePaymentConfirmed(
  admin: ReturnType<typeof serviceClient>,
  reservationId: string,
) {
  const { data: res } = await admin
    .from("reservations")
    .select("id, prestataire_id")
    .eq("id", reservationId)
    .maybeSingle();

  const prestataireId = res?.prestataire_id as string | undefined;
  if (!prestataireId) return;

  const { data: prest } = await admin
    .from("prestataire_profiles")
    .select("user_id")
    .eq("id", prestataireId)
    .maybeSingle();
  const userId = prest?.user_id as string | undefined;
  if (!userId) return;

  const { data: profile } = await admin
    .from("user_profiles")
    .select("fcm_token")
    .eq("user_id", userId)
    .maybeSingle();
  const token = profile?.fcm_token as string | null | undefined;
  if (!token) return;

  await sendFcmNotification({
    token,
    title: "MadBeauty",
    body: "Paiement confirmé — nouvelle réservation",
    data: { reservationId },
  });
}

async function markEventProcessed(
  admin: ReturnType<typeof serviceClient>,
  event: Stripe.Event,
): Promise<boolean> {
  const { data } = await admin
    .from("stripe_webhook_events")
    .select("id")
    .eq("id", event.id)
    .maybeSingle();

  if (data?.id) return false;

  const { error } = await admin.from("stripe_webhook_events").insert({
    id: event.id,
    type: event.type,
    payload: event.data.object,
  });

  if (error?.code === "23505") return false;
  if (error) throw error;
  return true;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET");
  if (!webhookSecret) {
    console.error("STRIPE_WEBHOOK_SECRET manquant");
    return new Response("Webhook non configuré", { status: 500 });
  }

  const signature = req.headers.get("stripe-signature");
  if (!signature) {
    return new Response("Signature manquante", { status: 400 });
  }

  const stripe = stripeClient();
  const body = await req.text();

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(
      body,
      signature,
      webhookSecret,
    );
  } catch (e) {
    console.error("Webhook signature invalide", e);
    return new Response("Signature invalide", { status: 400 });
  }

  const admin = serviceClient();

  try {
    const isNew = await markEventProcessed(admin, event);
    if (!isNew) {
      return new Response(JSON.stringify({ ok: true, duplicate: true }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    switch (event.type) {
      case "payment_intent.amount_capturable_updated": {
        const pi = event.data.object as Stripe.PaymentIntent;
        const { reservationId, created } = await ensureReservationForPaymentIntent(
          admin,
          pi,
        );
        // Secours si `complete_booking_after_payment` n'a pas encore tourné.
        if (created && reservationId) {
          await notifyPrestatairePaymentConfirmed(admin, reservationId);
        }
        break;
      }
      case "payment_intent.succeeded": {
        const pi = event.data.object as Stripe.PaymentIntent;
        const { reservationId } = await ensureReservationForPaymentIntent(
          admin,
          pi,
        );
        // Capture manuelle : `succeeded` = fonds capturés — ne pas modifier `statut`
        // (en_attente → confirmee → terminee reste géré par l'app).
        if (reservationId) {
          await admin
            .from("reservations")
            .update({ payment_status: "captured" })
            .eq("id", reservationId);
        }
        break;
      }
      case "payment_intent.payment_failed": {
        const pi = event.data.object as Stripe.PaymentIntent;
        await updateReservationPaymentByIntentId(admin, pi.id, "failed");
        break;
      }
      case "payment_intent.canceled": {
        const pi = event.data.object as Stripe.PaymentIntent;
        await updateReservationPaymentByIntentId(admin, pi.id, "canceled");
        break;
      }
      case "charge.captured": {
        const charge = event.data.object as Stripe.Charge;
        const piId = typeof charge.payment_intent === "string"
          ? charge.payment_intent
          : charge.payment_intent?.id;
        if (piId) {
          await updateReservationPaymentByIntentId(admin, piId, "captured");
        }
        break;
      }
      case "account.updated": {
        const account = event.data.object as Stripe.Account;
        await syncPrestataireByAccountId(admin, account);
        break;
      }
      default:
        console.log("Webhook ignoré:", event.type);
    }

    return new Response(JSON.stringify({ ok: true, type: event.type }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("stripe_webhook", e);
    return new Response(JSON.stringify({ ok: false, error: String(e) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
