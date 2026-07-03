# Restauration Stripe — MadBeauty

Checklist pour réintégrer les paiements (abonnement prestataire, acomptes réservation, Stripe Connect) après obtention d’un compte développeur **Organization** (Apple) et compte **Google Play** entreprise.

> **Contexte** : la version store actuelle (branche `deploy` ou équivalent) fonctionne sans paiement in-app (règlement sur place uniquement, accès catalogue via essai DB). Le code Stripe complet est **archivé sur la branche `features/v2`** ; les colonnes `stripe_*` en base sont conservées.

---

## 1. Prérequis comptes & Stripe

- [ ] Compte Apple Developer **Organization** (pas Individual)
- [ ] Compte Google Play Console (organisation)
- [ ] Compte Stripe (mode test puis live)
- [ ] Produits Stripe Billing : paliers solo / multi, mensuel / annuel
- [ ] Stripe Connect activé pour les prestataires
- [ ] Webhook Stripe configuré vers Supabase Edge Function

---

## 2. Récupérer le code depuis `features/v2`

**Branche de référence** : `features/v2` (locale et `origin/features/v2`) contient l’intégration Stripe complète — Flutter, Edge Functions, docs et migrations.

```bash
git fetch origin
git branch -a | grep features/v2   # vérifier que la branche est à jour
```

### Option A — Restaurer des chemins précis (recommandé)

Sur ta branche de travail (ex. `main`, `deploy`) :

```bash
git checkout features/v2 -- \
  pubspec.yaml \
  pubspec.lock \
  lib/services/stripe/ \
  lib/shared/widgets/stripe/ \
  lib/core/config/stripe_test_mode.dart \
  lib/core/constants/strings/discovery/disc_stripe_connect.dart \
  lib/features/booking/logic/booking_payment_flow.dart \
  lib/features/profile/screens/client_payment_methods_screen.dart \
  lib/features/prestataire/screens/prestataire_payment_methods_screen.dart \
  lib/features/prestataire/widgets/profile/overview/payments/ \
  lib/features/prestataire/widgets/profile/overview/sections/prestataire_payment_methods_section.dart \
  lib/features/prestataire/widgets/profile/subscription/prestataire_subscription_checkout_section.dart \
  lib/features/prestataire/widgets/subscription/prestataire_subscription_billing_cards_section.dart \
  docs/STRIPE_CONNECT_SETUP.md \
  docs/STRIPE_SUBSCRIPTION_SETUP.md \
  docs/STRIPE_TEST_FLOW.md \
  supabase/functions/_shared/stripe_booking.ts \
  supabase/functions/_shared/stripe_connect.ts \
  supabase/functions/_shared/stripe_reservation.ts \
  supabase/functions/_shared/prestataire_subscription.ts \
  supabase/functions/stripe_webhook/ \
  supabase/functions/stripe_connect_redirect/ \
  supabase/functions/create_booking_payment_intent/ \
  supabase/functions/complete_booking_after_payment/ \
  supabase/functions/capture_booking_payment/ \
  supabase/functions/create_prestataire_subscription_checkout/ \
  supabase/functions/sync_prestataire_subscription/ \
  supabase/functions/create_prestataire_billing_portal/ \
  supabase/functions/create_client_billing_portal/ \
  supabase/functions/list_client_payment_methods/ \
  supabase/functions/list_prestataire_payment_methods/ \
  supabase/functions/prepare_client_customer_sheet/ \
  supabase/functions/prepare_prestataire_customer_sheet/ \
  supabase/functions/prestataire_connect_onboarding/ \
  supabase/functions/prestataire_connect_sync/
```

Puis récupérer à la main (fichiers modifiés des deux côtés, conflits probables) :

- `lib/main.dart` — initialisation `Stripe.instance`
- `lib/core/config/app_config.dart` — clés publishable
- `lib/router/detail_routes.dart`, `client_profile_routes.dart` — routes paiement
- `lib/router/navigation_extensions.dart`, `app_deep_links.dart`, `deep_link_listener.dart`
- `android/app/src/main/AndroidManifest.xml` — intent-filters Stripe
- `ios/` — merchant ID si configuré
- `.env.example`
- Hub prestataire : `wizardStepCount = 7`, étape abonnement, widgets paliers / checkout
- Chaînes UI : `disc_presta_subscription.dart`, `disc_payment.dart`, `disc_payment_methods.dart`

Comparer avec `features/v2` :

```bash
git diff features/v2 -- lib/main.dart lib/router/ lib/features/booking/
```

### Option B — Fusionner toute la branche

```bash
git checkout ta-branche-cible
git merge features/v2
# Résoudre les conflits en gardant Stripe + les évolutions post-store (messagerie, etc.)
```

À utiliser si tu veux tout récupérer d’un coup ; prévoir une revue manuelle importante.

### Option C — Consulter sans checkout

```bash
git show features/v2:lib/services/stripe/stripe_service.dart
git diff deploy..features/v2 --stat
```

### Fichiers Flutter principaux à restaurer

| Zone | Chemins |
|------|---------|
| Dépendance | `pubspec.yaml` → `flutter_stripe` |
| Services | `lib/services/stripe/*` |
| Widgets | `lib/shared/widgets/stripe/*` |
| Config | `lib/core/config/stripe_test_mode.dart`, clés dans `.env` |
| Chaînes UI | `lib/core/constants/strings/discovery/disc_stripe_connect.dart` |
| Booking | `lib/features/booking/logic/booking_payment_flow.dart` |
| Écrans client | `lib/features/profile/screens/client_payment_methods_screen.dart` |
| Écrans prestataire | `lib/features/prestataire/screens/prestataire_payment_methods_screen.dart` |
| Widgets paiement | `prestataire_stripe_connect_tile.dart`, `prestataire_payment_methods_section.dart`, `client_payment_methods_section.dart` |
| Abonnement UI | `prestataire_subscription_checkout_section.dart`, `prestataire_subscription_billing_cards_section.dart`, cartes paliers / intervalles |
| Routes | `/client/payment-methods`, `/prestataire/payment-methods` dans `detail_routes.dart`, `client_profile_routes.dart` |
| Deep links | `AndroidManifest.xml`, `auth_deep_link_handler.dart`, `app_deep_links.dart` |
| `main.dart` | initialisation `Stripe.instance` |

### Edge Functions Supabase à redéployer

```bash
supabase functions deploy stripe_webhook
supabase functions deploy stripe_connect_redirect
supabase functions deploy create_booking_payment_intent
supabase functions deploy complete_booking_after_payment
supabase functions deploy capture_booking_payment
supabase functions deploy create_prestataire_subscription_checkout
supabase functions deploy sync_prestataire_subscription
supabase functions deploy create_prestataire_billing_portal
supabase functions deploy create_client_billing_portal
supabase functions deploy list_client_payment_methods
supabase functions deploy list_prestataire_payment_methods
supabase functions deploy prepare_client_customer_sheet
supabase functions deploy prepare_prestataire_customer_sheet
supabase functions deploy prestataire_connect_onboarding
supabase functions deploy prestataire_connect_sync
```

Modules partagés :

- `supabase/functions/_shared/stripe_booking.ts`
- `supabase/functions/_shared/stripe_connect.ts`
- `supabase/functions/_shared/stripe_reservation.ts`
- `supabase/functions/_shared/prestataire_subscription.ts`

---

## 3. Secrets Supabase

Dans le dashboard Supabase → **Project Settings → Edge Functions → Secrets** :

| Secret | Usage |
|--------|--------|
| `STRIPE_SECRET_KEY` | API Stripe |
| `STRIPE_WEBHOOK_SECRET` | Vérification webhook |
| `STRIPE_PRICE_SOLO_MONTHLY` | Abonnement 1 service |
| `STRIPE_PRICE_SOLO_YEARLY` | |
| `STRIPE_PRICE_MULTI_MONTHLY` | 2+ services |
| `STRIPE_PRICE_MULTI_YEARLY` | |
| Variables Connect / redirect URLs | Voir `docs/STRIPE_CONNECT_SETUP.md` (à restaurer) |

---

## 4. Variables d’environnement Flutter

Dans `.env` (voir `.env.example`) :

```env
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_MERCHANT_IDENTIFIER=merchant.com.madbeauty
```

Relancer :

```bash
flutter pub get
cd ios && pod install && cd ..
```

---

## 5. UI & parcours à réactiver

- [ ] Étape 7 « Abonnement » du hub prestataire (`wizardStepCount = 7`)
- [ ] Écran « Mon abonnement » avec paliers et CTA Stripe Checkout
- [ ] « Recevoir mes paiements » (Stripe Connect) dans le profil prestataire
- [ ] Choix acompte 20 % / sur place à la réservation
- [ ] Écrans « Moyens de paiement » client et prestataire
- [ ] Icône carte dans l’en-tête espace prestataire (web + mobile)
- [ ] Bandeaux essai / visibilité avec CTA paiement
- [ ] Gate abonnement sur agenda / réservations

---

## 6. Base de données

Les colonnes suivantes existent déjà (pas de migration destructive nécessaire) :

- `prestataire_profiles` : `stripe_customer_id`, `stripe_subscription_id`, `subscription_status`, etc.
- `reservations` : `stripe_payment_intent_id`, `payment_status`, `amount_cents`
- Tables clients / cartes si créées par migrations antérieures

Vérifier `docs/DB_SCHEMA.md` et les migrations dans `supabase/migrations/`.

---

## 7. Tests avant mise en production

1. **Abonnement** : essai → checkout → webhook `customer.subscription.*` → visibilité catalogue
2. **Connect** : onboarding prestataire → compte `charges_enabled`
3. **Réservation** : acompte 20 % → PaymentIntent → confirmation → capture
4. **Deep links** : retour app après checkout / portail billing
5. **Annulation** : remboursement selon politique Stripe
6. `flutter analyze` + tests unitaires booking / abonnement

Carte de test Stripe : `4242 4242 4242 4242`, expiration future, CVC quelconque.

---

## 8. Soumission stores (après restauration)

- Déclarer les **achats in-app** / abonnements auto-renouvelables (Apple)
- Politique de confidentialité et CGV mentionnant Stripe
- Compte développeur en **Organization** requis pour les paiements réels
- Captures d’écran montrant le flux de paiement pour la review

---

## 9. Rollback rapide

Si besoin de republier sans Stripe :

1. Rester sur la branche **sans Stripe** (`deploy` ou équivalent) — ne pas merger `features/v2`
2. Ne pas déployer les Edge Functions Stripe (ou les désactiver)
3. Laisser les colonnes DB en place (lecture seule côté app)

> `features/v2` reste l’archive Stripe : ne pas la supprimer tant que la réintégration n’est pas terminée en production.

---

## Références sur `features/v2`

- `docs/STRIPE_CONNECT_SETUP.md`
- `docs/STRIPE_SUBSCRIPTION_SETUP.md`
- `docs/STRIPE_TEST_FLOW.md`
- `docs/MODELE_TARIFAIRE.md` (grille solo / multi)
