---
name: madbeauty-performance
description: >-
  Fluidité et stabilité MadBeauty avant prod : images en cache (cached_network_image),
  compression uploads, dispose des controllers, timeout Supabase 10s, providers
  autoDispose, réduction des rebuilds Riverpod, build release. Utiliser pour toute
  modif UI/réseau/état, pré-lancement, perf, memory leaks, ou quand l'utilisateur
  mentionne fluidité, stabilité, release, DevTools ou Image.network.
---

# MadBeauty — performance & stabilité

## Contrainte production

Traiter chaque optimisation comme si l'application devait tenir une charge de production très élevée.

- privilégier les solutions stables, mesurables et maintenables
- éviter les rebuilds, requêtes, allocations et traitements inutiles
- penser latence, mémoire, batterie, timeouts, retry et dégradation réseau
- éviter les optimisations fragiles qui marchent en dev mais se dégradent à grande échelle

Checklist à appliquer sur **chaque** modif qui touche UI, images, uploads, providers ou Supabase.

## 1. Images réseau — cache obligatoire

**Interdit** : `Image.network` nu dans `lib/` (sauf implémentation interne de `AppNetworkImage`).

**Obligatoire** :
- Affichage → `AppNetworkImage` (`lib/shared/widgets/app/app_network_image.dart`)
- Avatars → `AppAvatar` (`lib/shared/widgets/app/app_avatar.dart`)
- Les deux utilisent `cached_network_image` (cache disque + mémoire)

```dart
AppNetworkImage(
  url: imageUrl,
  fit: BoxFit.cover,
  width: w,
  height: h,
  placeholder: customWidget, // optionnel
  error: customWidget,       // optionnel
)
```

Vérification :
```bash
# doit retourner 0 résultat hors app_network_image.dart (implémentation interne)
rg "Image\.network" lib --glob "*.dart"
```

## 2. Uploads images — compression centralisée

Tous les uploads passent par `StorageService` (`lib/services/supabase/storage/storage_service.dart`) :
- `uploadAvatar`, `uploadRealisation`, `uploadReviewPhoto`, `uploadChatAttachment`
- Compression via `flutter_image_compress` : max 1280px, qualité 82, JPEG
- Validation : `StorageService.validateImageFile` avant upload

**Ne pas** appeler `uploadBinary` / `.upload` ailleurs. Nouveau type d'upload → ajouter une méthode dans `StorageService` qui réutilise `_uploadImage`.

## 3. Controllers — pas de memory leaks

Tout `TextEditingController`, `ScrollController`, `AnimationController`, `TabController`, `FocusNode` créé dans un `State` doit être `dispose()` dans `dispose()`.

Pattern :
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

Contrôleurs délégués à une classe (ex. `PrestataireServiceFieldSet`, `RegisterWizardFormController`) → la classe expose `dispose()` et l'écran parent l'appelle.

**Exception acceptable** : spinners dans les boutons d'action (`AppButton`, envoi formulaire) — pas de shimmer plein écran à la place.

## 4. Timeout Supabase — 10 s

Config dans `lib/core/config/app_config.dart` :
```dart
static const Duration supabaseHttpTimeout = Duration(seconds: 10);
static const Duration supabaseRealtimeTimeout = Duration(seconds: 10);
```

Client HTTP : `SupabaseTimeoutHttpClient` (`lib/services/supabase/supabase_http_client.dart`), injecté dans `SupabaseService.initialize()` avec `realtimeClientOptions.timeout`.

**Ne pas** retirer ni augmenter sans discussion explicite. Pour un appel ponctuel plus long, timeout local sur l'action — pas sur le client global.

## 5. Providers Riverpod — autoDispose

| Type | Stratégie |
|------|-----------|
| Données d'écran (liste, détail, recherche) | `FutureProvider.autoDispose` / `StreamProvider.autoDispose` |
| Session globale (rôles, profil client, auth) | `FutureProvider` sans autoDispose |
| Badge shell toujours monté | Garder sans autoDispose si le shell `watch` en permanence |
| Services Supabase / Stripe | `Provider` (singleton léger) |

Providers déjà en autoDispose côté écrans : `prestataireDetailProvider`, `messagesProvider`, `clientReservationsProvider`, `homeProfileSnapshotProvider`, etc.

Nouveau provider fetch par écran → **commencer par autoDispose** ; passer en global seulement si invalidation cross-écrans nécessaire.

### Réduire les rebuilds

Préférer `ref.watch(provider.select((v) => …))` quand seule une valeur scalaire est lue :

```dart
// Bon — rebuild seulement si le count change
final count = ref.watch(
  clientPendingReservationsCountProvider.select((a) => a.value ?? 0),
);

// Éviter — rebuild sur loading/error/data même si seul .value compte
final count = ref.watch(clientPendingReservationsCountProvider).value ?? 0;
```

Cibles prioritaires : shell navigation (badges), gate providers abonnement prestataire, en-têtes avec plusieurs watches.

## 6. États UI async

Shimmer, vide, erreur, retry, snackbars → skill **`madbeauty-ux-states`** (obligatoire sur tout écran async).

## 7. Profilage DevTools (avant release)

```bash
flutter run --profile --dart-define-from-file=.env
```

Dans Flutter DevTools :
1. **Performance** — parcourir Accueil → Listing → Détail → Booking → Chat ; repérer jank > 16 ms
2. **Rebuild Stats** — widgets qui rebuildent > 5× par navigation
3. Cibles fréquentes : `ClientHomeHeroHeader`, longues `ListView`, carrousels images

Corrections typiques : `select`, `const` constructors, `RepaintBoundary` sur cartes lourdes, éviter `setState` dans `build`.

## 8. Validation pré-release

```bash
flutter pub get
dart analyze lib
flutter test
flutter build apk --release
# ou flutter build appbundle --release
```

APK attendu : `build/app/outputs/flutter-apk/app-release.apk`

## Checklist rapide (copier en fin de tâche)

```
- [ ] Aucun Image.network nu (AppNetworkImage / AppAvatar)
- [ ] Upload image → StorageService + compression
- [ ] Nouveaux controllers → dispose()
- [ ] Nouveau provider fetch écran → autoDispose
- [ ] ref.watch avec select si lecture partielle
- [ ] dart analyze sans erreur
- [ ] build release OK si changement structurant
```

## Fichiers de référence

| Sujet | Fichier |
|-------|---------|
| Images cache | `lib/shared/widgets/app/app_network_image.dart` |
| Avatars | `lib/shared/widgets/app/app_avatar.dart` |
| Upload + compress | `lib/services/supabase/storage/storage_service.dart` |
| Timeout HTTP | `lib/services/supabase/supabase_http_client.dart` |
| Init Supabase | `lib/services/supabase/supabase_service.dart` |
| Constantes timeout | `lib/core/config/app_config.dart` |
| Réservations / badges | `lib/features/booking/providers/booking_session_providers.dart` |
| Gate abonnement | `lib/features/prestataire/providers/subscription/prestataire_subscription_gate_provider.dart` |
