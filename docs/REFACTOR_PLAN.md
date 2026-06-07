# Plan de refactor architecture — MadBeauty

Document opérationnel aligné sur `.cursor/skills/madbeauty/SKILL.md` et `docs/ARCHITECTURE.md`.  
Objectif : réduire la dette **sans bloquer le MVP** — petits PRs, une zone à la fois.

---

## Principes (à ajouter dans la skill)

1. **`services/` n’importe jamais `features/*/screens` ni `features/*/widgets`.**
2. **Modèles partagés** → `core/models/domain/` (ou `core/models/dto/` pour view-state réutilisé).
3. **Logique pure** (formatters, règles, eligibility) → `core/logic/` ou `features/<x>/logic/` **sans** import Flutter UI.
4. **Fichier > ~400 lignes** → scinder (notifier + widgets + layout).
5. **Routes** → un fichier `routes/` par feature, assemblés dans `app_router.dart`.

---

## Vue d’ensemble des phases

| Phase | Priorité | Effort | Impact |
|-------|----------|--------|--------|
| **0** — Garde-fous | Immédiat | 1 h | Évite la dette future |
| **1** — Modèles & dépendances services | Haute | 2–3 j | Corrige l’inversion de couches |
| **2** — God screens | Haute | 3–5 j | Lisibilité + tests |
| **3** — Routeur modulaire | Moyenne | 2 j | Maintenance navigation |
| **4** — Providers & notifications | Basse | 1–2 j | Cohérence Riverpod |

Chaque phase = **1 ou plusieurs PR** (`refactor/phase-N-…`).

---

## Phase 0 — Garde-fous (immédiat)

### 0.1 Mettre à jour la skill

Fichier : `.cursor/skills/madbeauty/SKILL.md`

Ajouter une section **« Dépendances interdites »** :

- `services/` → pas de `features/*/screens`, `features/*/widgets`
- `core/` → pas d’import `features/`
- `shared/widgets/` → pas d’import `features/` (sauf extensions navigation si déjà existant)

### 0.2 Script de contrôle (optionnel)

```bash
# Imports services → features (à tendre vers 0 pour screens/widgets/providers UI)
rg "import '\.\./.*features/" lib/services --glob "*.dart"
```

### 0.3 Definition of Done par PR refactor

```bash
flutter analyze
flutter test
# Pas de changement de comportement visible (smoke manuel zone touchée)
```

---

## Phase 1 — Modèles & inversion de dépendances

**Problème** : ~25 fichiers dans `lib/services/` importent `features/` (modèles, logic, providers).

### 1.1 Déplacer les modèles « métier partagés » vers `core/`

| Fichier actuel | Destination proposée | Statut |
|----------------|----------------------|--------|
| `features/prestataire/models/prestataire_reservation_item.dart` | `core/models/domain/booking/prestataire_reservation_item.dart` | **Fait** (shim export conservé) |
| `features/booking/models/client_reservation_summary.dart` | `core/models/domain/booking/client_reservation_summary.dart` | **Fait** (shim export conservé) |
| `features/booking/logic/reservation_payment_display.dart` | `core/logic/booking/reservation_payment_display.dart` | **Fait** (shim export conservé) |
| `features/prestataire/models/prestataire_dashboard_data.dart` | `core/models/domain/prestataire/prestataire_dashboard_data.dart` | **Fait** |
| `features/messaging/models/conversation_inbox_item.dart` | `core/models/domain/messaging/conversation_inbox_item.dart` | **Fait** |
| `features/messaging/models/conversation_inbox_item.dart` | `core/models/domain/messaging/conversation_inbox_item.dart` | messaging_service, inbox UI |
| `features/prestataire/models/prestataire_subscription_status.dart` | `core/models/domain/prestataire/subscription_status.dart` | stripe services |
| `features/admin/models/*` | `core/models/domain/admin/*` | admin services |

**Étapes par modèle :**

1. Copier le fichier dans `core/models/domain/…`
2. Mettre à jour les exports / imports (`package:madbeauty/core/…`)
3. Laisser un `export` temporaire à l’ancien chemin (1 PR) ou supprimer directement (petit modèle)
4. `dart run build_runner build` si Freezed
5. `flutter analyze` + tests ciblés

### 1.2 Déplacer la logique pure vers `core/logic/`

| Fichier actuel | Destination | Statut |
|----------------|-------------|--------|
| `features/booking/logic/reservation_payment_display.dart` | `core/logic/booking/reservation_payment_display.dart` | **Fait** |
| `features/booking/logic/booking_create_failure.dart` | `core/logic/booking/booking_create_failure.dart` | **Fait** |
| `features/booking/logic/booking_pricing.dart` | `core/logic/booking/booking_pricing.dart` | **Fait** |
| `features/booking/logic/client_reservation_ui_status.dart` | `core/logic/booking/client_reservation_ui_status.dart` | **Fait** |
| `features/booking/logic/reservation_chat_eligibility.dart` | `core/logic/messaging/reservation_chat_eligibility.dart` | **Fait** |
| `features/messaging/logic/chat_message_moderator.dart` | `core/logic/messaging/chat_message_moderator.dart` | **Fait** |

### 1.3 Casser `services` → `features/providers`

Fichiers critiques :

| Fichier | Import problématique | Solution |
|---------|---------------------|----------|
| `offline_sync_service.dart` | `prestataire_agenda_provider`, `prestataire_dashboard_provider` | **Fait** — hook `offlineSyncAfterFlushProvider` + `features/offline/providers/offline_booking_sync_invalidation.dart` (override dans `main.dart`) |
| `booking_service_providers.dart` | `auth_notifier`, `guest_mode`, `current_prestataire` | Garder les providers dans `services/` mais déplacer la **composition** dans `features/booking/providers/` qui lit auth + appelle le service |
| `booking_push_coordinator.dart` | auth, referral, favorites providers | Déplacer vers `features/notifications/` ou `services/notifications/` **sans** dépendre des providers : passer des callbacks depuis `app.dart` / shell |
| `prestataire_booking_notification_coordinator.dart` | providers prestataire | Idem — orchestration dans feature shell |

**Pattern cible :**

```
features/booking/providers/booking_service_facade.dart  → compose auth + service
services/supabase/booking/booking_service.dart          → uniquement core/models + supabase
```

### 1.4 PR suggérées (phase 1)

1. `refactor/move-booking-domain-models`
2. `refactor/move-prestataire-domain-models`
3. `refactor/move-messaging-domain-models`
4. `refactor/booking-service-decouple-providers`
5. `refactor/offline-sync-invalidate-hooks`

---

## Phase 2 — Découper les god files

### 2.1 `prestataire_hub_screen.dart` (~1583 lignes)

**Cible :** écran < 250 lignes + notifier + steps existants.

| Extraire vers | Contenu |
|---------------|---------|
| `prestataire/providers/prestataire_hub_form_notifier.dart` | État formulaire, validation, save, upload, horaires |
| `prestataire/logic/prestataire_hub_save_pipeline.dart` | Enchaînement save (profil, services, photos) |
| `prestataire/widgets/profile/hub/prestataire_hub_screen_body.dart` | Arbre widgets du hub |
| Garder dans `screens/` | `Scaffold`, `AppBar`, branchement provider |

**Ordre :**

1. Extraire le **notifier** (état + méthodes async) — aucun changement UI
2. Extraire **widgets** déjà partiellement dans `prestataire_hub_layout.dart` (842 lignes) — fusionner responsabilités
3. Réduire l’écran à glue code

### 2.2 `register_wizard_screen.dart` (~1577 lignes)

Même approche que auth/login (déjà bien découpé) :

| Extraire vers |
|---------------|
| `auth/register/wizard/register_wizard_notifier.dart` |
| `auth/register/wizard/register_wizard_steps.dart` (déjà partiel ?) |
| Un widget par étape si > 300 lignes |

### 2.3 `booking_service.dart` (~744 lignes)

| Extraire vers |
|---------------|
| `services/supabase/booking/booking_queries.dart` — sélections SQL / maps |
| `services/supabase/booking/booking_mappers.dart` — row → domain models |
| `services/supabase/booking/booking_prestataire_ops.dart` — liste / statuts prestataire |
| `services/supabase/booking/booking_client_ops.dart` — réservations client |

`BookingService` devient une façade mince.

### 2.4 Autres fichiers > 500 lignes (priorité secondaire)

| Fichier | Action |
|---------|--------|
| `prestataire_analytics_panel.dart` (1039) | Split cartes + graphiques + provider dédié |
| `prestataire_services_guided_wizard.dart` (1009) | Une étape = un fichier widget |
| `booking_confirmation_screen.dart` (892) | Notifier paiement + sections widgets |
| `prestataire_hub_layout.dart` (842) | Sous-layouts par section hub |
| `prestataire_catalog_list_card.dart` (672) | Compact / expanded déjà partiels — vérifier `IntrinsicHeight` + `LayoutBuilder` |

### 2.5 PR suggérées (phase 2)

1. `refactor/prestataire-hub-notifier`
2. `refactor/prestataire-hub-ui-split`
3. `refactor/register-wizard-notifier`
4. `refactor/booking-service-split`

---

## Phase 3 — Routeur modulaire

**Fichier actuel :** `router/app_router.dart` (~779 lignes, ~53 routes).

### 3.1 Créer des modules routes (calquer `auth/login/routes/`)

| Nouveau fichier | Routes |
|-----------------|--------|
| `features/home/routes/client_home_routes.dart` | accueil client shell branche 0 |
| `features/listing/routes/listing_routes.dart` | recherche, all prestataires |
| `features/booking/routes/booking_routes.dart` | réservation, confirmation, historique client |
| `features/messaging/routes/messaging_routes.dart` | inbox, chat |
| `features/prestataire/routes/prestataire_shell_routes.dart` | shell + dashboard, agenda, clients, messages, profil |
| `features/prestataire/routes/prestataire_stack_routes.dart` | hub, horaires, détail RDV, abonnement |
| `features/profile/routes/profile_routes.dart` | profil client, edit, become prestataire |
| `router/shell_routes.dart` | `StatefulShellRoute` client / prestataire / admin |

### 3.2 `app_router.dart` cible (~150 lignes)

```dart
// app_router.dart — assemblage uniquement
routes: [
  ...authRoutes,
  ...shellRoutes(ref),
  ...prestataireStackRoutes,
],
redirect: authRedirect(ref),
```

### 3.3 PR suggérée

1. `refactor/router-extract-prestataire`
2. `refactor/router-extract-client-shell`
3. `refactor/router-slim-app-router`

---

## Phase 4 — Providers & UI hors place

### 4.1 Convention providers

| Type | Emplacement |
|------|-------------|
| Provider **lié à un écran** | `features/<x>/providers/` |
| Provider **lié à un service global** | `services/<x>/<x>_providers.dart` |
| Provider **transverse** (offline, runtime) | `core/providers/` |

Documenter dans SKILL : « Si le provider ne fait qu’exposer un `Service` + mappe vers UI locale → feature. Si plusieurs features consomment → `services/` ou `core/`. »

### 4.2 Notifications UI

| Fichier actuel | Destination |
|----------------|-------------|
| `services/notifications/in_app_notifications_sheet.dart` | `shared/widgets/notifications/` ou `features/notifications/widgets/` |
| Coordinators push | `features/notifications/` (orchestration) + `services/notifications/` (FCM brut) |

### 4.3 Features « coquilles »

| Feature | Action |
|---------|--------|
| `search/` (alias listing) | Supprimer et rediriger route vers `listing` **ou** documenter comme alias officiel |
| `client/` (3 widgets) | Fusionner dans `shared/widgets/client/` ou `features/home/widgets/workspace/` |
| `trust/` | Compléter ou fusionner dans `features/prestataire/` / `features/reviews/` |

---

## Ordre d’exécution recommandé

```
Semaine 1   Phase 0 + Phase 1.1 (modèles booking/prestataire)
Semaine 2   Phase 1.3 (découpler booking_service_providers + offline sync)
Semaine 3   Phase 2.1 (hub notifier — plus gros ROI prestataire)
Semaine 4   Phase 2.3 (booking_service split)
Semaine 5   Phase 3 (router prestataire + client shell)
Semaine 6+  Phase 2.2, 2.4, Phase 4 (selon besoin produit)
```

---

## Checklist par PR

- [ ] Scope unique (un god file OU un groupe de modèles)
- [ ] Aucun changement fonctionnel intentionnel
- [ ] `flutter analyze` OK
- [ ] `flutter test` OK
- [ ] Smoke test manuel de la zone (voir tableau ci-dessous)
- [ ] SKILL / ARCHITECTURE mis à jour si nouvelle convention

### Smoke tests par zone

| Zone | Parcours minimal |
|------|------------------|
| Booking | Recherche → fiche → créneau → confirmation |
| Prestataire hub | Modifier profil + enregistrer |
| Agenda prestataire | Liste RDV + accepter / terminé |
| Offline | Mode avion → ouvrir agenda → reconnexion |
| Push | (optionnel) création RDV test |
| Navigation | Tous les onglets client + prestataire |

---

## Métriques de succès

| Métrique | Aujourd’hui | Cible 3 mois |
|----------|-------------|--------------|
| Fichiers > 800 lignes | 4 | 0 |
| Imports `services/` → `features/` | ~25 | < 5 (providers seulement, puis 0) |
| Lignes `app_router.dart` | ~779 | < 200 |
| Routes co-localisées | auth only | client + prestataire + booking |

---

## Ce qu’il ne faut **pas** refactoriser maintenant

- Refonte graphique / design system
- Migration vers repository pattern complet (trop lourd pour le ROI actuel)
- Split en packages mono-repo (`packages/booking/`, etc.) — seulement si équipe > 3 devs
- Changement stack (Bloc, AutoRoute, etc.)

---

*Dernière mise à jour : généré depuis l’audit architecture du dépôt MadBeauty.*
