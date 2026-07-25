# Stripe Connect & paiements MadBeauty

Guide pour activer les paiements clients et les virements aux prestataires.

## 1. Créer un compte Stripe

1. [https://dashboard.stripe.com/register](https://dashboard.stripe.com/register)
2. Activer le **mode test** (interrupteur en haut à droite).
3. Récupérer les clés : **Developers → API keys**
   - `pk_test_...` → `.env` / `STRIPE_PUBLISHABLE_KEY`
   - `sk_test_...` → secret Supabase (jamais dans Flutter)

## 2. Activer Stripe Connect

1. Dashboard → **Connect** → **Commencer** / **Settings**
2. Choisir le modèle **Plateforme** (les prestataires sont des comptes connectés).
3. Type de compte connecté : **Express** (recommandé pour l’onboarding simplifié).
4. Renseigner les informations de la plateforme MadBeauty (nom, URL, etc.).

## 3. Secrets Supabase

```bash
npx supabase secrets set STRIPE_SECRET_KEY=sk_test_VOTRE_CLE
npx supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_VOTRE_SECRET
npx supabase secrets set STRIPE_PLATFORM_FEE_PERCENT=10
# Ne pas définir RETURN/REFRESH en com.madbeauty:// — Stripe refuse (not a valid URL).
# Laisser vide : les Edge Functions utilisent stripe_connect_redirect (HTTPS → deep link app).
```

## 4. Migrations base

```bash
npx supabase db push
```

Applique notamment :

- colonnes paiement sur `reservations`
- colonnes Connect sur `prestataire_profiles`
- table `stripe_webhook_events` (idempotence)

## 5. Déployer les Edge Functions

```bash
npx supabase functions deploy create_booking_payment_intent
npx supabase functions deploy complete_booking_after_payment
npx supabase functions deploy capture_booking_payment
npx supabase functions deploy prestataire_connect_onboarding
npx supabase functions deploy prestataire_connect_sync
npx supabase functions deploy stripe_connect_redirect --no-verify-jwt
npx supabase functions deploy stripe_webhook --no-verify-jwt
```

## 6. Webhook Stripe

1. Dashboard → **Developers → Webhooks → Add endpoint**
2. URL :

   `https://VOTRE_PROJECT_REF.supabase.co/functions/v1/stripe_webhook`

3. Événements à cocher :

   - `payment_intent.amount_capturable_updated`
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `payment_intent.canceled`
   - `charge.captured`
   - `account.updated`

4. Copier le **Signing secret** (`whsec_...`) → `STRIPE_WEBHOOK_SECRET`

## 7. Onboarding prestataire (app)

1. Compte **prestataire** → onglet **Profil**
2. Section **Recevoir mes paiements** → **Configurer Stripe Connect**
3. Compléter le formulaire Stripe (identité + IBAN test)
4. Revenir dans l’app → **Actualiser le statut** → statut **Compte actif**

En test, Stripe fournit des données fictives (ex. IBAN `FR8930006000011234567890145`).

## 8. Flux paiement client

| Étape | Acteur | Action | DB attendue |
|-------|--------|--------|-------------|
| 1 | Client | Récap → **Payer et confirmer** | — |
| 2 | Stripe | PaymentSheet — carte `4242 4242 4242 4242` | PI `requires_capture` |
| 3 | Serveur | `complete_booking_after_payment` | `statut=en_attente`, `payment_status=authorized` |
| 4 | Prestataire | **Confirmer** la réservation (agenda) | `statut=confirmee` |
| 5 | Prestataire | Marquer **terminée** | `statut=terminee` |
| 6 | Serveur | `capture_booking_payment` + webhook | `payment_status=captured`, virement Connect |

Checklist détaillée : **[TEST_FLOW.md](./TEST_FLOW.md)**.

## 9. Cartes de test

| Numéro | Résultat |
|--------|----------|
| `4242 4242 4242 4242` | Succès |
| `4000 0000 0000 0002` | Refus |
| `4000 0025 0000 3155` | 3D Secure |

Date future, CVC `123`.

## 10. Dépannage

| Problème | Vérification |
|----------|----------------|
| Prestataire non payable | Connect onboarding terminé ? `stripe_connect_charges_enabled = true` |
| Webhook 400 | `STRIPE_WEBHOOK_SECRET` correct |
| `not a valid URL` (Connect) | Supprimer les secrets `STRIPE_CONNECT_*` en `com.madbeauty://` ; déployer `stripe_connect_redirect` |
| Paiement sans réservation | Logs `stripe_webhook` et `complete_booking_after_payment` |
| Double réservation | Index unique sur `stripe_payment_intent_id` |
