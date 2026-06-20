---
name: madbeauty
description: >-
  Contexte projet MadBeauty (Flutter, Riverpod, go_router, Supabase) — réservation
  beauté client/prestataire. Utiliser pour toute tâche sur ce dépôt : features,
  widgets, providers, routes, services, tests, docs, commits ou PR. Couvre la
  structure en trio (screens/widgets/providers), l’exploration de l’existant
  avant création de fichier, le découpage en sous-dossiers si un dossier est
  trop chargé, et l’obligation d’un design responsive sur tous les écrans.
---

# MadBeauty — contexte projet

## Contrainte production (obligatoire)

**Toujours raisonner comme pour une application de production utilisée à très grande échelle.**  
Chaque tâche doit prendre en compte la robustesse, la maintenabilité, la performance, la sécurité, l'observabilité et l'évolutivité.

Attendus minimums sur toute modification :

- éviter les solutions fragiles ou uniquement "qui marchent en local"
- privilégier des choix lisibles, testables et faciles à faire évoluer
- limiter les rebuilds inutiles, appels réseau redondants et traitements coûteux
- anticiper les cas limites, erreurs réseau, états vides et comportements concurrents
- préserver la cohérence des données, la sécurité et les garde-fous produit
- suivre des pratiques comparables à celles attendues dans de grandes applications en production

En cas d'arbitrage, préférer la solution la plus fiable en prod plutôt que la plus rapide à coder.

## Stack

- **Flutter / Dart 3.8+** — iOS & Android
- **Riverpod 3** — état (`AsyncNotifier`, `Notifier`, `StreamProvider`)
- **go_router** — navigation, `redirect`, routes nommées (`AppNavigationX`)
- **Freezed + json_serializable** — modèles dans `lib/core/models/domain/`
- **Supabase** — Auth, PostgreSQL, Storage, Realtime, Edge Functions
- **Stripe Connect** — paiements prestataires

## Couches (`lib/`)

| Dossier | Rôle |
|---------|------|
| `features/` | UI + logique par domaine (`screens/`, `widgets/`, `providers/`, parfois `models/`, `logic/`, `routes/`) |
| `services/` | Accès données (Supabase, auth, réseau, cache, Stripe…) |
| `core/` | Config, constantes, erreurs (`AppFailure`), modèles domaine, providers transverses |
| `router/` | `GoRouter`, politiques d’accès, shell client/prestataire |
| `shared/` | Thème (`AppArea` vert client / bleu prestataire), widgets réutilisables |

**Règle** : pas de logique métier lourde dans les seuls widgets ; orchestration dans controllers/notifiers.

## Design responsive (obligatoire)

**Toujours adapter le design à l’écran** — compact, téléphone, tablette et large. Aucun écran ne doit être pensé pour une seule taille.

- Avant toute UI : lire le skill **`madbeauty-responsive`**
- Réutiliser `DiscoveryResponsive` (`lib/shared/layout/discovery_responsive.dart`) et les widgets `shared/` existants
- Vérifier safe area, clavier, scroll, centrage `maxWidth` sur grands écrans
- Pas de largeurs fixes sans `clamp` / breakpoint / `LayoutBuilder`

### Dépendances interdites

- `services/` → **pas** de `features/*/screens`, `features/*/widgets`
- `services/` → éviter `features/*/providers` (préférer callbacks / façade côté feature)
- `core/` → **pas** d’import `features/`
- Fichier **> ~400 lignes** → scinder (notifier + widgets) — voir `docs/REFACTOR_PLAN.md`

## Organisation des fichiers

### Trio de base par feature

Chaque module sous `features/<nom>/` repose sur **trois dossiers** :

```
features/<feature>/
├── screens/      # pages / écrans routés
├── widgets/      # composants UI de la feature
└── providers/    # état Riverpod de la feature
```

Ajouter au besoin (en suivant l’existant) : `models/`, `logic/`, `routes/`, `navigation/`, `theme/`.

Sous-feature plus large (ex. `auth/login/`, `auth/register/`) : **même trio** à l’intérieur du sous-dossier.

### Avant de créer un fichier

1. **Explorer l’existant** : lister le dossier concerné, grep le préfixe (`client_home_`, `prestataire_`, `listing_`…).
2. **Préférer étendre** un widget / provider / screen existant plutôt qu’un doublon.
3. **Copier les conventions** : nommage, imports relatifs, `ConsumerWidget` vs `ConsumerStatefulWidget`, structure des routes voisines.

Ne pas créer de fichier « from scratch » sans avoir lu au moins un fichier comparable dans la même feature.

### Emplacement correct

| Contenu | Où |
|---------|-----|
| Écran routé | `features/<feature>/screens/` ou `…/<sous-feature>/screens/` |
| Widget UI spécifique | `features/<feature>/widgets/` |
| État / fetch | `features/<feature>/providers/` ou `services/` si partagé |
| Modèle Freezed domaine | `core/models/domain/` |
| Modèle view-state local | `features/<feature>/models/` |
| Route go_router | `features/<feature>/routes/` ou `router/` si transversal |
| Widget réutilisé par plusieurs features | `shared/widgets/` |
| Accès Supabase | `services/supabase/` |

### Dossiers trop chargés → sous-dossiers

Si un dossier (`widgets/`, `providers/`, etc.) accumule **beaucoup de fichiers** ou mélange **plusieurs sous-domaines**, le scinder par thème — comme déjà fait ailleurs :

- `prestataire/widgets/profile/overview/`, `…/dashboard/`, `…/agenda/`
- `auth/login/`, `auth/register/`, `auth/reset_password/`

Critères pour créer un sous-dossier : ~**8 fichiers** du même préfixe, ou un bloc UI clairement distinct (ex. `home/widgets/client_home/` vs widgets prestataire).

## Commandes utiles

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # après modèles Freezed
flutter run --dart-define-from-file=.env
flutter analyze
flutter test
```

Variables via `--dart-define-from-file=.env` (voir `.env.example`). **Ne jamais committer `.env`.**

## Git & PR

- Branches : `feature/…`, `fix/…`, `chore/…`, `docs/…`
- Commits : Conventional Commits (`feat(scope): …`, `fix: …`) — voir `docs/CONTRIBUTING.md`
- PR : `flutter analyze`, `flutter test`, `build_runner` si Freezed, migrations testées si SQL
- Fichiers générés `*.freezed.dart` / `*.g.dart` : **commités**

## Rôles produit

- **Client** : découverte, réservation, messagerie, avis, favoris
- **Prestataire** : agenda, services, horaires, dashboard, abonnement Stripe

Périmètre MVP vs V2 : `docs/FEATURES.md`.

## Skills complémentaires

- **Design UI** (ergonomie, AppColors, composants) → skill `madbeauty-ui-design`
- Design responsive (tous écrans) → skill `madbeauty-responsive`
- Textes UI → skill `madbeauty-ui-strings`
- Migrations / Edge Functions / RLS → skill `madbeauty-supabase`
- **Polish UX** (shimmer, vide/erreur/retry, snackbars, placeholders) → skill `madbeauty-ux-states`
- **Perf & stabilité** (cache images, uploads, timeout Supabase, autoDispose, release) → skill `madbeauty-performance`

## Références détaillées

- Architecture : [reference.md](reference.md) ou `docs/ARCHITECTURE.md`
- Plan de refactor : `docs/REFACTOR_PLAN.md`
- Schéma BDD : `docs/DB_SCHEMA.md`
