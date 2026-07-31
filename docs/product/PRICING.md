# Modèle tarifaire MadBeauty

Référence produit pour les frais client, les paiements de prestation et l’abonnement prestataire.

## 1. Frais plateforme client (réservations)

| Règle | Détail |
|--------|--------|
| **1ʳᵉ et 2ᵉ réservation** | Aucun frais MadBeauty (1 €). |
| **À partir de la 3ᵉ réservation** | **1 €** de frais plateforme par réservation, prélevés **dans l’app** à la confirmation (**option A**). |

Le frais de 1 € est distinct du prix de la prestation et revient à la plateforme.

### Option A — confirmation

- **Acompte 20 %** : paiement app = **20 % du service + 1 €** (si ≥ 3ᵉ résa) ; solde **80 % sur place**.
- **Paiement intégral sur place** : paiement app = **1 € seul** (si ≥ 3ᵉ résa) ; prestation **100 % chez le prestataire** le jour J.
- **1ʳᵉ / 2ᵉ résa + sur place** : aucun paiement dans l’app (confirmation directe).
- **1ʳᵉ / 2ᵉ résa + acompte 20 %** : **20 %** dans l’app uniquement (Connect requis).

## 2. Paiement de la prestation (client)

| Mode | Comportement |
|------|----------------|
| **`deposit_20`** | 20 % via Stripe Connect → prestataire ; 80 % sur place. Nécessite un compte Connect actif. |
| **`on_site`** | 0 % prestation dans l’app ; règlement intégral chez le prestataire. |

### Remises (ordre d’application)

1. Parrainage (−10 % une fois) si actif  
2. **VIP salon** (−5 %) si ≥ 3 RDV `terminee` chez ce presta (`SalonVipConfig`)  
3. Fidélité (couverture jusqu’à 50 €) si activée au checkout  

Snapshot : `reservations.referral_discount_percent`, `vip_discount_percent`, `loyalty_reward_cents`.

## 3. Abonnement prestataire

| Profil | Mensuel | Annuel |
|--------|---------|--------|
| **1 service** publié | 14,99 € | 150 € |
| **2 services ou plus** | 17,99 € | 180 € |

Constantes : `lib/core/config/prestataire_subscription_config.dart`.  
Paiement : Stripe Checkout (abonnement) + webhooks — voir [../payments/SUBSCRIPTION.md](../payments/SUBSCRIPTION.md).

## 4. Implémentation technique

| Élément | Emplacement |
|---------|-------------|
| Constantes (1 €, 20 %, seuil 3ᵉ résa) | `lib/core/config/pricing_config.dart` |
| Calcul montants | `lib/features/booking/logic/booking_pricing.dart` |
| Même règles côté serveur | `supabase/functions/_shared/booking_pricing.ts` |
| Colonnes réservation | migration `20260601120000_booking_payment_modes.sql` |
| PaymentIntent | `create_booking_payment_intent` |

Commission variable historique (`STRIPE_PLATFORM_FEE_PERCENT`) : non appliquée sur le modèle cible ; la plateforme retient `platform_fee_cents` (+ éventuel pourcentage legacy si configuré sur la part prestataire).

## 5. UI (état d’implémentation)

| Écran | Statut |
|-------|--------|
| Récap confirmation (choix 20 % / sur place) | Fait |
| Liste + détail réservation **client** | Fait |
| Agenda + détail + dashboard **prestataire** | Fait |
| Profil + dashboard → **Mon abonnement** (affichage + paiement) | Fait |
| Facturation Stripe Subscriptions | Fait (configurer les `price_` côté Supabase) |

## 6. Légende statuts réservation (compteur)

Pour le seuil « 3ᵉ réservation », on compte les réservations du client dont le statut **n’est pas** `annulee` / `cancelled`.
