# Documentation MadBeauty

Point d’entrée de la doc technique et produit. Commencer par **[ARCHITECTURE.md](./ARCHITECTURE.md)**.

## Organisation

| Dossier | Contenu |
|---------|---------|
| Racine | Architecture, contribution |
| [`product/`](./product/) | Feuille de route, tarifs, partage fiche |
| [`backend/`](./backend/) | Schéma PostgreSQL / RLS |
| [`payments/`](./payments/) | Stripe Connect, abonnements, tests |
| [`notifications/`](./notifications/) | Push FCM / Edge Functions |
| [`store/`](./store/) | App Store Connect, setup iOS |
| [`engineering/`](./engineering/) | Plan de refactor |

## Index rapide

| Document | Rôle |
|----------|------|
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Stack, couches `lib/`, navigation, intégrations |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Branches, Conventional Commits, PR |
| [product/FEATURES.md](./product/FEATURES.md) | État produit / prochaines étapes |
| [product/PRICING.md](./product/PRICING.md) | Frais client, acompte, abonnement |
| [product/PRESTATAIRE_SHARE.md](./product/PRESTATAIRE_SHARE.md) | Liens de partage fiche prestataire |
| [backend/DB_SCHEMA.md](./backend/DB_SCHEMA.md) | Tables, relations, RLS, Realtime, Storage |
| [payments/](./payments/README.md) | Guides Stripe |
| [notifications/PUSH.md](./notifications/PUSH.md) | FCM, webhooks réservation / messages |
| [store/APP_STORE_CONNECT.md](./store/APP_STORE_CONNECT.md) | Textes & confidentialité App Store |
| [store/IOS_SETUP.md](./store/IOS_SETUP.md) | Sign in with Apple, capabilities, APNs |
| [engineering/REFACTOR_PLAN.md](./engineering/REFACTOR_PLAN.md) | Dette architecture, phases restantes |

Hors `docs/` : checklist auth prod → [`supabase/AUTH_PRODUCTION_CHECKLIST.md`](../supabase/AUTH_PRODUCTION_CHECKLIST.md).
