# Paiements Stripe — MadBeauty

Guides pour Connect (réservations), Billing (abonnement prestataire) et tests mode test.

> Règles produit (1 €, acompte 20 %, paliers abonnement) : [../product/PRICING.md](../product/PRICING.md).  
> Politique app : Stripe activé surtout sur **Web** (`StripePlatformPolicy`) tant que les stores n’autorisent pas le flux choisi.

## Documents

| Fichier | Contenu |
|---------|---------|
| [CONNECT.md](./CONNECT.md) | Compte Stripe, secrets, Edge Functions Connect, webhook, onboarding |
| [SUBSCRIPTION.md](./SUBSCRIPTION.md) | Prix Billing, Checkout, portail client, tests abonnement |
| [TEST_FLOW.md](./TEST_FLOW.md) | Checklist bout-en-bout Connect → paiement → capture |

## Ordre recommandé (première config)

1. [CONNECT.md](./CONNECT.md) — clés, migrations, deploy functions, webhook réservation / Connect  
2. [SUBSCRIPTION.md](./SUBSCRIPTION.md) — 4 `price_…`, secrets, événements abonnement  
3. [TEST_FLOW.md](./TEST_FLOW.md) — parcours manuel mode test  

## Edge Functions (rappel)

**Réservation / Connect** : `create_booking_payment_intent`, `complete_booking_after_payment`, `capture_booking_payment`, `prestataire_connect_onboarding`, `prestataire_connect_sync`, `stripe_connect_redirect`, `stripe_webhook`.

**Abonnement** : `create_prestataire_subscription_checkout`, `create_prestataire_billing_portal`, `sync_prestataire_subscription` (+ même `stripe_webhook`).

Schéma colonnes : [../backend/DB_SCHEMA.md](../backend/DB_SCHEMA.md).
