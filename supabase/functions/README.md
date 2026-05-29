# Edge Functions MadBeauty

## Notifications (FCM)

| Fonction | Déclencheur | Cible |
|----------|-------------|--------|
| `on_booking_created` | `INSERT reservations` | prestataire |
| `on_booking_updated` | `UPDATE reservations` | client (statut) |
| `on_message_created` | `INSERT messages` | autre participant |

Partagé : `_shared/booking_notify.ts`

```bash
npx supabase functions deploy on_booking_created --no-verify-jwt
npx supabase functions deploy on_booking_updated --no-verify-jwt
npx supabase functions deploy on_message_created --no-verify-jwt
```

## Paiements Stripe + Connect

| Fonction | Auth | Rôle |
|----------|------|------|
| `create_booking_payment_intent` | JWT client | PaymentIntent (capture manuelle, Connect) |
| `complete_booking_after_payment` | JWT client | Crée la réservation après PaymentSheet |
| `capture_booking_payment` | JWT prestataire | Capture après prestation terminée |
| `prestataire_connect_onboarding` | JWT prestataire | Crée compte Express + lien onboarding |
| `prestataire_connect_sync` | JWT prestataire | Synchronise statut Connect |
| `stripe_webhook` | Signature Stripe | Webhooks (réservations + comptes) |

Partagé : `_shared/stripe_booking.ts`, `stripe_connect.ts`, `stripe_reservation.ts`

### Secrets

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_PLATFORM_FEE_PERCENT` (défaut `10`)
- `STRIPE_CONNECT_RETURN_URL` / `STRIPE_CONNECT_REFRESH_URL` (deep links mobile)

```bash
npx supabase functions deploy create_booking_payment_intent
npx supabase functions deploy complete_booking_after_payment
npx supabase functions deploy capture_booking_payment
npx supabase functions deploy prestataire_connect_onboarding
npx supabase functions deploy prestataire_connect_sync
npx supabase functions deploy stripe_webhook --no-verify-jwt
```

Documentation complète : **`docs/STRIPE_CONNECT_SETUP.md`**.

## Test local

```bash
npx supabase functions serve
```
