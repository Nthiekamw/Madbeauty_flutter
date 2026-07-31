# Edge Functions MadBeauty

## Notifications (FCM)

| Fonction | Déclencheur | Cible |
|----------|-------------|--------|
| `on_booking_created` | `INSERT reservations` | prestataire |
| `on_booking_updated` | `UPDATE` / `DELETE reservations` | client (statut) + liste d'attente (créneau libéré) |
| `on_message_created` | `INSERT messages` | autre participant (booking ou inquiry via `conversation_id`) |
| `on_wishlist_product_updated` | `UPDATE produits_boutique` (restock / prix) | clients wishlist |
| `on_dispute_updated` | `INSERT/UPDATE booking_disputes` | client + prestataire |
| `on_user_support_message_created` | `INSERT user_support_messages` | utilisateur ou admins |
| `on_boutique_order_created` | `INSERT` / passage `paid` boutique | prestataire |
| `on_boutique_order_updated` | `UPDATE statut` boutique | client |

Partagé : `_shared/booking_notify.ts`

```bash
npx supabase functions deploy on_booking_created --no-verify-jwt
npx supabase functions deploy on_booking_updated --no-verify-jwt
npx supabase functions deploy on_message_created --no-verify-jwt
npx supabase functions deploy on_wishlist_product_updated --no-verify-jwt
npx supabase functions deploy on_dispute_updated --no-verify-jwt
npx supabase functions deploy on_user_support_message_created --no-verify-jwt
npx supabase functions deploy on_boutique_order_created --no-verify-jwt
npx supabase functions deploy on_boutique_order_updated --no-verify-jwt
```

## Bugs signalés (push admins + e-mail)

| Fonction | Déclencheur | Cible |
|----------|-------------|--------|
| `on_bug_report_created` | `INSERT bug_reports` (Database Webhook) | push FCM admins + e-mail équipe |
| `on_bug_report_updated` | `UPDATE bug_reports` (statut résolu/classé) | push FCM reporter |
| `on_bug_report_message_created` | `INSERT bug_report_messages` | push FCM admin ou reporter |

Partagé : `_shared/bug_report_notify.ts`

### Webhooks Supabase

- Table `bug_reports`, event `INSERT` → `on_bug_report_created`
- Table `bug_reports`, event `UPDATE` → `on_bug_report_updated`
- Table `bug_report_messages`, event `INSERT` → `on_bug_report_message_created`
- Header : `x-webhook-secret` = `CONTENT_REPORT_WEBHOOK_SECRET`

```bash
npx supabase functions deploy on_bug_report_created --no-verify-jwt
npx supabase functions deploy on_bug_report_updated --no-verify-jwt
npx supabase functions deploy on_bug_report_message_created --no-verify-jwt
```

## Signalements (e-mail équipe)

| Fonction | Déclencheur | Cible |
|----------|-------------|--------|
| `on_content_report_created` | `INSERT content_reports` (Database Webhook) | e-mails équipe modération |

Partagé : `_shared/admin_notify.ts`

### Secrets

- `RESEND_API_KEY` — clé API [Resend](https://resend.com)
- `CONTENT_REPORT_NOTIFY_EMAILS` — destinataires séparés par des virgules (ex. `equipe@madbeauty.app,support@madbeauty.app`)
- `CONTENT_REPORT_MAIL_FROM` — expéditeur (défaut `MadBeauty <noreply@madbeauty.app>`, domaine vérifié chez Resend)
- `CONTENT_REPORT_WEBHOOK_SECRET` — secret header `x-webhook-secret` (sinon repli sur `BOOKING_WEBHOOK_SECRET`)

### Webhook Supabase

Dans le dashboard : **Database → Webhooks → Create** :

- Table : `content_reports`
- Events : `INSERT`
- Type : Supabase Edge Function → `on_content_report_created`
- Header : `x-webhook-secret` = valeur de `CONTENT_REPORT_WEBHOOK_SECRET`

```bash
npx supabase functions deploy on_content_report_created --no-verify-jwt
```

## Vérifications prestataire (e-mail équipe)

| Fonction | Déclencheur | Cible |
|----------|-------------|--------|
| `on_verification_requested` | `INSERT prestataire_verification_events` où `action = requested` | e-mails équipe |
| `on_verification_decided` | `INSERT prestataire_verification_events` où `action ∈ {approved, revoked}` | push FCM prestataire |

Réutilise les secrets Resend / destinataires des signalements (`CONTENT_REPORT_NOTIFY_EMAILS` ou `ADMIN_NOTIFY_EMAILS`).

### Webhook Supabase

- Table : `prestataire_verification_events`
- Events : `INSERT`
- Type : Edge Function → `on_verification_requested`
- Header : `x-webhook-secret` = `CONTENT_REPORT_WEBHOOK_SECRET`

```bash
npx supabase functions deploy on_verification_requested --no-verify-jwt
```

## Paiements Stripe + Connect

| Fonction | Auth | Rôle |
|----------|------|------|
| `create_booking_payment_intent` | JWT client | PaymentIntent (capture manuelle, Connect) |
| `complete_booking_after_payment` | JWT client | Crée la réservation après PaymentSheet |
| `capture_booking_payment` | JWT prestataire | Capture après prestation terminée |
| `prestataire_connect_onboarding` | JWT prestataire | Crée compte Express + lien onboarding |
| `prestataire_connect_sync` | JWT prestataire | Synchronise statut Connect |
| `list_client_payment_methods` | JWT client | Liste les cartes enregistrées |
| `prepare_client_customer_sheet` | JWT client | Customer Sheet (ajout / suppression cartes) |
| `create_client_billing_portal` | JWT client | Portail web (secours) |
| `list_prestataire_payment_methods` | JWT prestataire | Cartes d’abonnement prestataire |
| `prepare_prestataire_customer_sheet` | JWT prestataire | Customer Sheet abonnement prestataire |
| `create_boutique_order_payment_intent` | JWT client | PaymentIntent boutique (capture auto, Connect) |
| `stripe_webhook` | Signature Stripe | Webhooks (réservations + boutique + comptes) |

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
npx supabase functions deploy list_client_payment_methods
npx supabase functions deploy prepare_client_customer_sheet
npx supabase functions deploy create_client_billing_portal
npx supabase functions deploy list_prestataire_payment_methods
npx supabase functions deploy prepare_prestataire_customer_sheet
npx supabase functions deploy create_boutique_order_payment_intent
npx supabase functions deploy stripe_webhook --no-verify-jwt
```

Documentation complète : **`docs/payments/CONNECT.md`**.

## Test local

```bash
npx supabase functions serve
```
