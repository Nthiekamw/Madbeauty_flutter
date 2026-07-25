# Feuille de route MadBeauty — état produit

Synthèse de ce qui est **en place** sur la branche de travail actuelle vs **prochaines étapes** (maturité prod / stores). Alignée sur [ARCHITECTURE.md](../ARCHITECTURE.md).

## En place (parcours crédible)

### Authentification & compte

- [x] Splash + session Supabase
- [x] E-mail / mot de passe (inscription, confirmation, reset)
- [x] OAuth Google + Sign in with Apple (iOS)
- [x] Rôles client / prestataire (`user_roles` + cache local)
- [x] Profils métier créés à l’activation du rôle
- [x] Biométrie (optionnelle), suppression de compte

### Navigation & UX

- [x] `go_router` + garde d’auth + deep links
- [x] Shells client / prestataire / admin ; thème `AppArea` + dark mode
- [x] Responsive mobile + Flutter Web (`DiscoveryResponsive`, shell adaptatif)
- [x] Chaînes centralisées (`lib/core/constants/`)

### Parcours client

- [x] Découverte / listing (filtres, carte)
- [x] Fiche prestataire + services + créneaux
- [x] Réservation (création, liste, détail, statuts)
- [x] Messagerie liée aux réservations + Realtime
- [x] Avis, favoris, parrainage
- [x] Partage de fiche ([PRESTATAIRE_SHARE.md](./PRESTATAIRE_SHARE.md))

### Parcours prestataire

- [x] Hub profil / onboarding, catalogue services, horaires
- [x] Agenda (accepter / refuser / terminer)
- [x] Dashboard & analytics
- [x] Abonnement Stripe (Checkout + portail) — UI + backend
- [x] Stripe Connect (encaissement prestations)

### Données & qualité

- [x] Migrations Supabase + modèles Freezed + codec domaine
- [x] Connectivité + cache local ; sync offline partielle
- [x] Push FCM (réservation + messages) — [notifications/PUSH.md](../notifications/PUSH.md)
- [x] Tests unitaires (auth, domaine, providers clés)

### Paiements (politique plateforme)

- [x] Code Stripe intégré (Connect + abonnement + PaymentIntent)
- [x] Règles tarifaires documentées — [PRICING.md](./PRICING.md)
- [ ] Paiements in-app **stores natifs** : aujourd’hui `StripePlatformPolicy` limite Stripe à **Web** (éviter IAP Apple/Google) — réactivation native sous contraintes stores

---

## Prochaines étapes (prod / scale)

### Paiements & stores

- Décision produit : Stripe natif vs IAP vs Web-only durable
- Passage clés **live**, webhooks prod, comptes Apple Organization / Play
- Textes & compliance App Store — [store/APP_STORE_CONNECT.md](../store/APP_STORE_CONNECT.md)

### Robustesse

- Stratégie offline-first élargie (conflits, files d’actions)
- Observabilité (Sentry / logs structurés)
- Tests E2E sur staging (device + backend)

### Produit

- Boutique produits + packs/offres (services et/ou produits) — panier, checkout, commandes presta + historique client (`feature/boutique-packs`)
  - Pack multi-services au **prix pack** (créneau durée cumulée) : prévu en itération suivante
- Modération avis / signalements avancée
- Badge `is_verified` (process manuel ou tiers)
- Admin : litiges, exports, outils pays / plans
- RGPD : export données, parcours suppression déjà amorcé

---

## Légende

- **[x]** : largement en place dans le dépôt.
- **[ ]** : prévu, partiel ou bloqué par contrainte store / ops.

Architecture : [ARCHITECTURE.md](../ARCHITECTURE.md) · Base : [DB_SCHEMA.md](../backend/DB_SCHEMA.md).
