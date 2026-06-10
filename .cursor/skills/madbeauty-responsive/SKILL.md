---
name: madbeauty-responsive
description: >-
  Design responsive MadBeauty (Flutter) : adapter systématiquement l’UI à toutes
  les tailles d’écran (compact, tablette, large). Utiliser pour tout écran,
  widget, formulaire, liste, grille, chat, modale ou refonte visuelle — jamais
  de layout figé pensé pour un seul téléphone.
---

# MadBeauty — design responsive

## Règle absolue

**Toujours adapter le design à l’écran**, quel que soit le device. Chaque écran ou widget livré doit rester lisible, utilisable et esthétique sur :

- **Compact** : &lt; 360 px (petits téléphones)
- **Téléphone** : 360–599 px
- **Tablette** : 600–899 px
- **Large** : ≥ 900 px (tablette paysage, desktop web)

Ne pas livrer de largeurs/hauteurs fixes « au pixel » sans borne (`clamp`) ni sans breakpoint.

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

Breakpoints déjà définis : `compactBreakpoint` 360, `tabletBreakpoint` 600, `wideBreakpoint` 900.

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
- [ ] Test mental : 320 px, 360 px, 390 px, 600 px, 900 px+
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
| Cartes accueil horizontales | `client_home_*` + `homeListCardWidth` |
| Champs sur 2 colonnes | `register_field_row.dart` |
| Action compacte | `MediaQuery.sizeOf(context).width < 390` (hub prestataire) |

## Anti-patterns

- Largeur fixe type `width: 400` sans `clamp` ni `maxWidth`
- `SizedBox(width: 300)` pour une carte sur toute la largeur écran
- Grille à 2 colonnes forcée sur 320 px sans réduire padding/espacement
- Ignorer `viewPadding` en bas (bouton masqué par la barre gestuelle)
- Dupliquer des breakpoints magiques : étendre `DiscoveryResponsive` si le seuil est réutilisé

## Étendre le système

Si un seuil ou une métrique sert à **plusieurs écrans**, l’ajouter dans `discovery_responsive.dart` plutôt que de recopier des constantes dans chaque widget.

## Skills liés

- Contexte projet → skill `madbeauty`
- Chaînes UI → skill `madbeauty-ui-strings`
