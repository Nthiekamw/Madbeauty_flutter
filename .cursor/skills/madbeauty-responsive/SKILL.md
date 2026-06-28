---
name: madbeauty-responsive
description: >-
  Design responsive MadBeauty (Flutter) : adapter systématiquement l’UI sur
  mobile natif (tous types d’écran : compact, téléphone, tablette) et sur
  Flutter Web (navigateur étroit, tablette, desktop). Utiliser pour tout écran,
  widget, formulaire, liste, grille, chat, modale, shell de navigation ou
  refonte visuelle — jamais de layout figé pensé pour un seul téléphone.
---

# MadBeauty — design responsive

## Contrainte production

Le responsive doit être pensé pour une application de production utilisée à très grande échelle, sur **mobile natif et web**.

- aucun overflow ou layout cassé sur tailles compactes, standard, tablette et large — **iOS, Android et navigateur**
- privilégier des layouts robustes, prévisibles et faciles à maintenir
- anticiper noms longs, textes dynamiques, badges, chargements, erreurs et contenu vide
- éviter les solutions « pile pour mon téléphone » qui cassent sur d'autres devices **ou sur le web**
- sur web : l’UI doit ressembler à un **site utilisable au clavier/souris**, pas à une app mobile étirée

## Règle absolue

**Toujours adapter le design à l’écran et à la plateforme.** Chaque écran ou widget livré doit rester lisible, utilisable et esthétique sur :

### Mobile natif (iOS / Android)

- **Compact** : &lt; 360 px (petits téléphones)
- **Téléphone** : 360–599 px
- **Tablette** : 600–899 px
- **Large** : ≥ 900 px (tablette paysage)

### Flutter Web (navigateur)

- **Web étroit** : &lt; 600 px — barre de navigation **en haut** (`WebShellTopNav`), pas de bottom nav
- **Web tablette / desktop** : ≥ 600 px — **NavigationRail** latéral (`AdaptiveShellScaffold`)
- **Desktop** : ≥ 1200 px — contenu centré, grilles plus denses (4 colonnes catalogue)

Ne pas livrer de largeurs/hauteurs fixes « au pixel » sans borne (`clamp`) ni sans breakpoint.

## Mobile vs web — comportements clés

| Contexte | Navigation shell | Contenu | Lisibilité |
|----------|------------------|---------|------------|
| Mobile natif | Bottom nav | Pleine largeur, scroll | Thème standard |
| **Web téléphone &lt; 600 px** | **Bottom nav (identique natif)** | **Pleine largeur, comme l'app** | Thème standard |
| Web tablette / desktop ≥ 600 px | Rail latéral + zone principale | Centré, `maxWidth` jusqu’à 1280 px | `WebReadabilityScope` |

Références :

- `lib/shared/layout/discovery_responsive.dart` — `useNativeMobileExperience`, `useWebSiteLayout`, grilles
- `lib/shared/layout/adaptive_shell_scaffold.dart` — shell client/prestataire adaptatif
- `lib/shared/widgets/layout/web_shell_top_nav.dart` — nav haut web étroit
- `lib/shared/widgets/layout/web_readability_scope.dart` — échelle texte/icônes web

Tester **toujours** les deux plateformes quand l’écran touche la navigation ou la mise en page globale : `flutter run` (device) **et** `flutter run -d chrome` (ou `.\scripts\run_flutter_web.ps1`).

## Avant de coder

1. Lire un écran **comparable** déjà responsive dans la même feature.
2. Vérifier `lib/shared/layout/discovery_responsive.dart` et les widgets `shared/` réutilisables.
3. Se poser : padding safe area, clavier, scroll, contenu centré sur grand écran, actions atteignables au pouce.

## Outils du projet (par priorité)

### 1. `DiscoveryResponsive` (préféré discovery / formulaires / listes)

```dart
final r = DiscoveryResponsive.of(context);

// Centrer et borner le contenu
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
  child: …,
)

// Padding horizontal cohérent
padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),

// Colonnes / empilement
if (r.useSideBySideFormRows) Row(…) else Column(…),
if (r.stackStepperActions) Column(…) else Row(…),
```

Breakpoints déjà définis : `compactBreakpoint` 360, `tabletBreakpoint` 600, `wideBreakpoint` 900, `desktopBreakpoint` 1200.

Flags web : `useNativeMobileExperience`, `useWebSiteLayout`, `useSidebarNavigation`, `catalogGridColumns`, `contentMaxWidth`.

### 2. `LayoutBuilder` (composant local)

Quand la décision dépend de la **largeur du parent**, pas de l’écran entier :

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 400) return Column(…);
    return Row(…);
  },
)
```

Existant : `register_field_row.dart`, `prestataire_dashboard_overview_grid.dart`.

### 3. `MediaQuery` (safe area, hauteur, cas ponctuels)

- `MediaQuery.sizeOf(context)` — largeur/hauteur écran
- `MediaQuery.viewPaddingOf(context)` / `paddingOf` — encoches, barre système, clavier
- `MediaQuery.viewInsetsOf(context).bottom` — composer chat au-dessus du clavier

Réserver `MediaQuery` aux cas où `DiscoveryResponsive` ne suffit pas (chat, bottom sheets, plein écran).

## Checklist livraison UI

```
- [ ] Mobile : test mental 320 px, 360 px, 390 px, 600 px, 900 px+
- [ ] Web : test mental 375 px, 600 px, 900 px, 1280 px (Chrome)
- [ ] Web : pas de bottom nav ; shell adaptatif (top nav ou rail)
- [ ] Pas de débordement horizontal (overflow) sur petit écran
- [ ] Texte : maxLines / ellipsis sur titres et previews
- [ ] Listes/grilles : nombre de colonnes ou largeur de carte adaptés
- [ ] Formulaires : champs empilés sur étroit, côte à côte si assez large
- [ ] Boutons / CTA : zone tactile ≥ 44 px, pas coupés par le safe area
- [ ] Modales / sheets : scroll si contenu long ; hauteur max relative à l’écran
- [ ] Images : BoxFit + contraintes max (pas de taille fixe seule)
- [ ] Grand écran : contenu centré avec maxWidth (pas de ligne illimitée)
```

## Patterns à réutiliser

| Besoin | Référence |
|--------|-----------|
| Scroll formulaire centré | `shared/widgets/discovery/discovery_form_scroll_view.dart` |
| Grille / catalogue | `listing_prestataires_scroll_view.dart` + `DiscoveryResponsive` |
| Shell navigation web | `adaptive_shell_scaffold.dart`, `web_shell_top_nav.dart` |
| Lisibilité web | `web_readability_scope.dart`, `web_readability.dart` |
| Cartes accueil horizontales | `client_home_*` + `homeListCardWidth` |
| Champs sur 2 colonnes | `register_field_row.dart` |
| Action compacte | `MediaQuery.sizeOf(context).width < 390` (hub prestataire) |

## Anti-patterns

- Largeur fixe type `width: 400` sans `clamp` ni `maxWidth`
- `SizedBox(width: 300)` pour une carte sur toute la largeur écran
- Grille à 2 colonnes forcée sur 320 px sans réduire padding/espacement
- Ignorer `viewPadding` en bas (bouton masqué par la barre gestuelle)
- Dupliquer des breakpoints magiques : étendre `DiscoveryResponsive` si le seuil est réutilisé
- Réutiliser la bottom nav mobile sur web (`kIsWeb` → shell adaptatif)
- Oublier `WebReadabilityScope` / tailles de texte trop petites sur navigateur desktop

## Étendre le système

Si un seuil ou une métrique sert à **plusieurs écrans**, l’ajouter dans `discovery_responsive.dart` plutôt que de recopier des constantes dans chaque widget.

## Skills liés

- Contexte projet → skill `madbeauty`
- Chaînes UI → skill `madbeauty-ui-strings`
