---
name: madbeauty-ux-states
description: >-
  Polish UX MadBeauty : shimmer cohérent, états vides/erreur/chargement avec retry,
  snackbars, placeholders images, pagination, mode hors-ligne. Utiliser pour tout
  écran async (Riverpod), liste, détail, formulaire, polish UX, états intermédiaires,
  ou quand l'utilisateur mentionne shimmer, vide, erreur réseau, retry, snackbar.
---

# MadBeauty — polish UX (états async)

## Contrainte production

Traiter chaque état async comme pour une application de production utilisée à grande échelle.

- prévoir chargement, vide, erreur, retry, offline partiel et rafraîchissement concurrent
- éviter les transitions cassées, spinners bloquants et retours utilisateur trop vagues
- privilégier des états fiables, cohérents et compréhensibles sur des millions d'usages
- penser résilience produit autant que confort visuel

À appliquer sur **chaque** écran ou section qui charge des données (`AsyncValue`, `FutureProvider`, pagination).

Complète le skill **`madbeauty-ui-design`** (charte visuelle) et **`madbeauty-performance`** (cache images, providers).

## Barrel widgets

```dart
import '../../../shared/widgets/discovery/discovery_widgets.dart';
// ou imports ciblés depuis shared/widgets/discovery/content/
```

| Widget | Usage |
|--------|--------|
| `DiscoveryListSkeleton` | Listes (réservations, favoris, admin, inbox…) |
| `DiscoveryDetailSkeleton` | Fiches / détail pleine page (profil, abonnement, reset password) |
| `DiscoveryInlineSkeleton` | Bandeau compact (checkout, plans, carte waitlist) |
| `DiscoverySectionError` | Erreur section + bouton Réessayer |
| `DiscoveryEmptyState` | Vide ou erreur pleine page avec CTA |
| `DiscoveryInlineErrorBanner` | Erreur pagination / chargement partiel |
| `DiscoveryShimmer` / `DiscoveryShimmerBox` | Shimmer custom |
| `DiscoveryAsyncBody` | Helper `AsyncValue` (si adapté) |

Images réseau : **`AppNetworkImage`** (placeholder shimmer intégré) — voir `madbeauty-performance`.

## Pattern Riverpod standard

```dart
async.when(
  loading: () => const DiscoveryListSkeleton(
    rowCount: 4,
    rowHeight: 100,
  ),
  error: (_, __) => DiscoveryEmptyState(
    icon: Icons.cloud_off_outlined,
    title: CoreStrings.networkErrorTitle,
    body: DiscList.emptyFilterTitle, // ou message métier
    actionLabel: DiscList.retry,
    onAction: () => ref.invalidate(monProvider),
  ),
  data: (items) => items.isEmpty
      ? DiscoveryEmptyState(
          icon: Icons.inbox_outlined,
          title: '…',
          body: '…',
        )
      : _buildList(items),
)
```

### Choisir le bon widget

| Contexte | Loading | Erreur |
|----------|---------|--------|
| Liste / écran principal | `DiscoveryListSkeleton` | `DiscoveryEmptyState` + retry |
| Section dans une page (accueil, dashboard) | `DiscoveryListSkeleton` (2–3 lignes) ou `DiscoveryInlineSkeleton` | `DiscoverySectionError` |
| Détail / fiche | `DiscoveryDetailSkeleton` | `DiscoverySectionError` ou `DiscoveryEmptyState` |
| Pagination « charger plus » | `DiscoveryInlineSkeleton` (hauteur ~28) | `DiscoveryInlineErrorBanner` |
| Zone embarquée très petite | `DiscoveryInlineSkeleton` | `DiscoverySectionError` compact |

**Retry** : toujours `ref.invalidate(provider)` (ou notifier dédié) — jamais un `Text('$e')` nu sans action.

## Textes utilisateur

| Constante | Rôle |
|-----------|------|
| `CoreStrings.networkErrorTitle` | Titre erreur réseau (« Connexion indisponible ») |
| `CoreStrings.networkErrorBody` | Corps générique réseau |
| `DiscList.retry` | Libellé bouton « Réessayer » |
| Fichiers `disc_*.dart` | Messages métier (vide filtres, réservations, etc.) |

Pas de chaînes en dur — skill **`madbeauty-ui-strings`**.

## Snackbars

Utiliser **`AppSnackBar`** (`lib/shared/widgets/app/app_snack_bar.dart`) :

```dart
AppSnackBar.success(context, DiscBooking.bookingCreatedSnack);
AppSnackBar.error(context, failure.message);
// ou extension :
context.showAppSnackBar(message: '…', kind: AppSnackKind.success);
```

- Succès après action (réservation créée, profil sauvegardé, etc.)
- Erreur utilisateur lisible (`AppFailure.message`) — pas de stack trace

## États vides vs erreur

| Situation | Icône typique | CTA |
|-----------|---------------|-----|
| Liste filtrée sans résultat | `Icons.search_off` | Réinitialiser filtres |
| Aucune donnée encore (première visite) | `Icons.inbox_outlined` | Action métier (réserver, compléter profil) |
| Erreur réseau / serveur | `Icons.cloud_off_outlined` | `DiscList.retry` |
| Invité / non connecté | `GuestAccountPrompt` ou empty dédié | Connexion |

`DiscoveryEmptyState` accepte `actionLabel` + `onAction` + `extraActions`.

## Images & placeholders

- Toute image URL → `AppNetworkImage` (shimmer pendant chargement, icône cassée en fallback)
- Avatars → `AppAvatar` (initiales en fallback)
- Promo / fallback custom : passer `placeholder:` et `error:` à `AppNetworkImage`

## Mode hors-ligne

- Shell client : `OfflineShell` (`lib/shared/widgets/layout/offline_shell.dart`) — bannière connectivité
- Listes avec cache : pattern `offlineDataLoader` + merge queue (voir réservations client)
- Erreur réseau : même widgets (`DiscoverySectionError`) ; le retry réessaie quand en ligne

## Ce qu'il ne faut **pas** remplacer

Garder `CircularProgressIndicator` dans :
- Boutons en cours d'action (`AppButton`, envoi, Google auth, sauvegarde)
- `startup_splash_screen.dart`
- Écrans de test dev (`async_state_test_screen.dart`)
- Pagination discrète acceptable si déjà en `DiscoveryInlineSkeleton` ailleurs

Remplacer les **spinners plein écran** et les **`Text` d'erreur sans retry**.

## Imports types

```dart
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../core/constants/app_strings.dart';
```

Ajuster la profondeur relative selon le fichier.

## Checklist rapide (fin de tâche UI async)

```
- [ ] loading → shimmer (pas CircularProgressIndicator plein écran)
- [ ] error → DiscoverySectionError ou DiscoveryEmptyState + invalidate
- [ ] vide → DiscoveryEmptyState avec message métier + CTA si pertinent
- [ ] pagination erreur → DiscoveryInlineErrorBanner
- [ ] succès action → AppSnackBar.success
- [ ] images → AppNetworkImage / AppAvatar
- [ ] textes dans disc_*.dart / CoreStrings
- [ ] dart analyze OK
```

## Références écrans déjà polis

S'inspirer de : `home_screen`, `listing_screen`, `client_reservations_screen`, `chat_screen`, `prestataire_dashboard`, écrans admin (`admin_users`, `admin_push`), `booking_confirmation_screen`, `profile_screen`.
