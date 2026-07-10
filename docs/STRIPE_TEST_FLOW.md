# Test du flux Stripe (mode test)

Checklist pour valider **Connect + paiement réservation + capture** sur le projet Supabase `vjjasrdoyguqkftfhaei`.

## Prérequis

| Élément | Vérification |
|---------|----------------|
| Mode test Stripe | Interrupteur « Test » activé dans le [Dashboard Stripe](https://dashboard.stripe.com/test/dashboard) |
| `.env` local | `STRIPE_PUBLISHABLE_KEY=pk_test_...`, `SUPABASE_URL`, `SUPABASE_ANON_KEY` |
| Secrets Supabase | `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, optionnel `STRIPE_PLATFORM_FEE_PERCENT=10` |
| Login CLI | `npx supabase login` puis `npx supabase secrets list` |
| Migrations | `npx supabase db push` (à jour) |
| Functions | Voir commandes dans `docs/STRIPE_CONNECT_SETUP.md` § 5 |
| Webhook | URL `https://vjjasrdoyguqkftfhaei.supabase.co/functions/v1/stripe_webhook` + événements listés dans le setup |
| Appareil | `flutter run --dart-define-from-file=.env` (un seul appareil USB si `adb` signale plusieurs devices) |

### Configurer les secrets (une fois)

```bash
npx supabase login
npx supabase secrets set STRIPE_SECRET_KEY=sk_test_VOTRE_CLE
npx supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_VOTRE_SECRET
npx supabase secrets set STRIPE_PLATFORM_FEE_PERCENT=10
```

Redéployer `stripe_webhook` après modification du handler :

```bash
npx supabase functions deploy stripe_webhook --no-verify-jwt
```

---

## Phase A — Onboarding prestataire Connect

1. Compte **prestataire** vérifié dans l’app (profil complet, `is_verified` si requis métier).
2. **Profil** → **Recevoir mes paiements** → **Configurer Stripe Connect**.
3. Formulaire Stripe test : identité fictive, IBAN test `FR8930006000011234567890145`.
4. Retour deep link `com.madbeauty.madbeauty://stripe-connect-return`.
5. **Actualiser le statut** → libellé **Compte actif**.

**SQL (Supabase SQL Editor, service role ou lecture admin)** :

```sql
select id, nom_salon,
       stripe_connect_account_id,
       stripe_connect_onboarding_status,
       stripe_connect_charges_enabled,
       stripe_connect_payouts_enabled
from prestataire_profiles
where user_id = '<uuid_auth_prestataire>';
```

Attendu : `stripe_connect_account_id` commence par `acct_`, `stripe_connect_charges_enabled = true`.

---

## Phase B — Réservation payante (client)

1. Compte **client** (pas le même user que le prestataire testé).
2. Choisir le prestataire avec Connect actif, un **service** avec prix > 0,50 €, un **créneau** libre.
3. Écran récap → **Payer et confirmer**.
4. PaymentSheet :
   - Carte : `4242 4242 4242 4242`
   - Date : tout mois/année futurs
   - CVC : `123`
5. Succès → écran **Réservation confirmée** (paiement enregistré).

**SQL** (remplacer `pi_...` par l’id affiché dans Stripe Dashboard → Payments si besoin) :

```sql
select id, statut, payment_status, amount_cents, currency,
       stripe_payment_intent_id, paid_at, date_heure
from reservations
order by created_at desc
limit 3;
```

| Champ | Valeur attendue juste après paiement |
|-------|--------------------------------------|
| `statut` | `en_attente` |
| `payment_status` | `authorized` |
| `stripe_payment_intent_id` | `pi_...` |
| `amount_cents` | prix service × 100 |

**Stripe Dashboard** : PaymentIntent en **Uncaptured** (`requires_capture`).

**Logs** : Supabase → Edge Functions → `create_booking_payment_intent`, `complete_booking_after_payment` sans 4xx/5xx.

---

## Phase C — Confirmation prestataire

1. Basculer sur le compte **prestataire**.
2. **Agenda** → ouvrir la réservation → **Confirmer** (ou action équivalente).
3. Vérifier `statut = confirmee`, `payment_status` toujours `authorized`.

---

## Phase D — Fin de prestation et capture

1. Toujours prestataire → marquer la réservation **Terminée** / réalisée.
2. L’app appelle `capture_booking_payment`.

**SQL** :

```sql
select id, statut, payment_status, stripe_payment_intent_id
from reservations
where id = '<reservation_id>';
```

| Champ | Valeur attendue |
|-------|-----------------|
| `statut` | `terminee` |
| `payment_status` | `captured` |

**Stripe Dashboard** : PaymentIntent **Succeeded**, onglet Connect → transfert vers le compte connecté (commission plateforme déduite).

**Webhook** : entrée dans `stripe_webhook_events` pour `payment_intent.succeeded` :

```sql
select id, type, processed_at
from stripe_webhook_events
order by processed_at desc
limit 5;
```

---

## Phase E — Reçu client

1. Compte client → **Mes réservations**.
2. La réservation payée affiche le **reçu** (montant, devise) si `payment_status` ∈ `authorized`, `captured`.

---

## Scénarios négatifs (optionnel)

| Scénario | Carte / action | Résultat attendu |
|----------|----------------|------------------|
| Refus | `4000 0000 0000 0002` | Message d’erreur, pas de réservation |
| Prestataire non payable | Prestataire sans Connect | `prestataire_not_payable` |
| Créneau pris | Deux clients même slot | Second : `slot_taken` |
| 3DS | `4000 0025 0000 3155` | Flux authentification puis succès |

---

## Dépannage rapide

| Symptôme | Piste |
|----------|--------|
| PaymentSheet ne s’ouvre pas | `STRIPE_PUBLISHABLE_KEY` dans `.env`, rebuild avec `--dart-define-from-file` |
| `prestataire_not_payable` | Onboarding Connect + `stripe_connect_charges_enabled` |
| Réservation absente après paiement | Logs `complete_booking_after_payment` ; webhook `amount_capturable` en secours |
| Impossible de terminer | Confirmer d’abord (`en_attente` → `confirmee`) |
| Webhook 400 | `STRIPE_WEBHOOK_SECRET` = signing secret de l’endpoint test |
| `terminee` repasse à `confirmee` | Redéployer `stripe_webhook` (correctif capture manuelle) |

---

## Test webhook en local (optionnel)

Installer [Stripe CLI](https://stripe.com/docs/stripe-cli), puis :

```bash
stripe login
stripe listen --forward-to https://vjjasrdoyguqkftfhaei.supabase.co/functions/v1/stripe_webhook
# Copier whsec_... affiché → supabase secrets set STRIPE_WEBHOOK_SECRET=...
stripe trigger payment_intent.amount_capturable_updated
```

Utile pour déboguer sans refaire un paiement mobile à chaque fois.
