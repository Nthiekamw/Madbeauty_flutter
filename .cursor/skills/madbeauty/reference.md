# MadBeauty — référence architecture

## Checklist avant un nouveau fichier

```
- [ ] J’ai listé les fichiers du dossier cible (Glob / exploration)
- [ ] Aucun widget / provider existant ne couvre déjà le besoin
- [ ] Le fichier ira dans screens / widgets / providers (ou sous-dossier équivalent)
- [ ] Le nom suit le préfixe de la feature (client_home_*, prestataire_*, disc_* pour les strings)
- [ ] Si le dossier parent est déjà dense, j’ai créé ou utilisé un sous-dossier thématique
- [ ] L’UI est responsive (skill `madbeauty-responsive`) : compact, tablette, large
```

## Design responsive

Voir skill **`madbeauty-responsive`**. Résumé :

- `DiscoveryResponsive.of(context)` — padding, `contentMaxWidth`, grilles, formulaires
- `LayoutBuilder` — comportement selon la largeur du parent
- `MediaQuery` — safe area, clavier, breakpoints ponctuels
- Fichier central : `lib/shared/layout/discovery_responsive.dart`

## Exemples de structure

**Feature simple** (`listing/`) :

```
listing/
├── screens/listing_screen.dart
├── widgets/listing_* …
├── providers/listing_* …
└── models/listing_quick_filter.dart
```

**Feature avec sous-modules** (`auth/`) :

```
auth/
├── login/       → screens/, providers/, routes/, logic/, models/
├── register/    → idem + widgets/
├── providers/   → auth_notifier, my_roles (partagés auth)
└── widgets/     → auth_form_scaffold, auth_error_banner (partagés)
```

**Widgets éclatés** (`prestataire/widgets/`) :

```
widgets/
├── profile/overview/   # profil prestataire
├── profile/steps/      # wizard hub
├── dashboard/          # accueil pro
├── agenda/             # rendez-vous
├── public/             # fiche vue client
├── workspace/          # shell pro
├── shared/             # tuiles / headers communs pro
└── dialogs/
```

## Flux UI → backend

```
Screen / Widget
  → Controller / Notifier (Riverpod)
    → Service / Repository
      → Supabase client / cache local
```

## Navigation

- `goRouterProvider` lit l’auth et applique `redirect`
- Rôle préféré mis en cache : `LocalCacheService.selectedRole`
- `RouterThemeScope` : thème selon `AppArea` (route client vs prestataire)

## Modèles domaine

- Emplacement : `lib/core/models/domain/`
- Sérialisation PostgREST : `SupabaseDomainCodec`
- Après modification : `dart run build_runner build --delete-conflicting-outputs`

## Tests

- Unitaires : validateurs, view states, controllers (overrides Riverpod), codec
- Emplacement : `test/unit/`

## Thème

- Couleurs / typo : `lib/shared/theme/`
- Widgets communs : `lib/shared/widgets/`

## Offline

- Fondations connectivité + cache ; enrichissement incrémental par feature
