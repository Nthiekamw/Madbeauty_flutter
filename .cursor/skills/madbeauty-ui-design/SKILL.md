---
name: madbeauty-ui-design
description: >-
  Design UI MadBeauty (Flutter) : écrans et widgets ergonomiques, intuitifs,
  attrayants, alignés sur l’identité visuelle et AppColors. Utiliser pour tout
  ajout ou changement de design, bannière, carte, formulaire, état vide, CTA,
  alerte, onboarding, polish UX ou refonte visuelle. États async → skill
  madbeauty-ux-states.
---

# MadBeauty — design UI

## Règle produit (verbatim)

Quand on ajoute ou change du design, ça doit **toujours** être :

- **Ergonomique** — lisible, zones tactiles ≥ 44 px, hiérarchie claire, une action principale évidente
- **Intuitif** — l’utilisateur comprend quoi faire sans lire un manuel
- **Attrayant** — soigné, cohérent, pas de UI « placeholder »
- **Aligné sur l’appli** — réutiliser les patterns et composants existants
- **Aligné sur les couleurs** — priorité à `lib/shared/theme/app_colors.dart` (`AppColors`), puis `Theme.of(context).colorScheme`

Compléter avec les skills **`madbeauty-responsive`** (toutes tailles d’écran), **`madbeauty-ui-strings`** (textes dans les fichiers de constantes) et **`madbeauty-ux-states`** (shimmer, chargement, erreur, retry, snackbars).

## Avant de coder une UI

1. **Lire un écran comparable** dans la même feature (client vs prestataire).
2. **Lister les widgets `shared/`** déjà adaptés (`DiscoverySurfaceCard`, `AppButton`, `AppTextField`, `DiscoveryFormScrollView`, `PrestataireSectionHeader`, etc.).
3. **Ne pas inventer** de palette hors `AppColors` / `colorScheme` (pas de `Colors.red` brut sauf transitoire debug).

## Tokens couleur (`AppColors`)

| Usage | Constantes |
|-------|------------|
| Fond / cartes clair | `lightSurface`, `cardSurfaceLight`, `workspacePanelFor(brightness)` |
| Texte principal | `lightOnSurface` / `darkOnSurface` ou `colorScheme.onSurface` |
| Texte secondaire | `lightOnSurfaceVariant` / `darkOnSurfaceVariant` |
| Marque / CTA principal | `brandBrown`, `brandBrownMid`, `colorScheme.primary` |
| Accent premium / mise en avant | `brandGold`, `brandGoldLight`, `brandGoldDark` |
| **Urgence / alerte action** | `notificationDot`, `errorLight` / `errorDark` |
| Erreur thème | `colorScheme.error`, `errorContainer` |

**Urgence visuelle** (abonnement, blocage, hors catalogue) : dégradé `notificationDot` → `errorLight`, barre latérale accent, bordure 1.5 px, ombre plus marquée, badge « Action requise », icône `priority_high` / `warning_amber`, CTA `FilledButton` en `notificationDot`.

**Succès / info calme** : `brandGold` ou `colorScheme.primary` avec alphas légers (0.12–0.2).

## Typographie

- Titres marquants : `AppFonts.display`, `FontWeight.w800`–`w900`, `letterSpacing: -0.2` à `-0.4`
- Corps : `AppFonts.body` ou `theme.textTheme.bodyMedium/Small`
- Ne pas mélanger plus de 2 graisses sur un même bloc

## Rayons & espacements

- Cartes discovery : `DiscoveryStyles.cardBorderRadius` (20), chips `chipBorderRadius` (14)
- Cartes workspace / profil : `BorderRadius.circular(16)` (voir `PrestataireProfileCompletionCard`)
- Padding page : `DiscoveryResponsive.horizontalPadding` ou `PrestataireProfileInsets.page(context)`

## Patterns à réutiliser (par priorité)

| Besoin | Référence |
|--------|-----------|
| Carte tappable avec gradient + progression | `prestataire_profile_completion_card.dart` |
| En-tête section icône + titre | `PrestataireSectionHeader` |
| Bandeau urgent abonnement | `prestataire_catalog_visibility_banner.dart` |
| État bloqué avec CTA | `prestataire_subscription_gate.dart` |
| Formulaire auth / inscription | `AuthStepSection`, `AppTextField`, `DiscoveryFormScrollView` |
| Liste vide / erreur | `DiscoveryEmptyState` — voir **`madbeauty-ux-states`** |
| Chargement liste | `DiscoveryListSkeleton` |
| Erreur section + retry | `DiscoverySectionError` |
| Feedback action | `AppSnackBar` |

## États async (obligatoire)

Tout écran Riverpod qui charge des données doit suivre **`madbeauty-ux-states`** :
- Shimmer cohérent (pas de spinner plein écran)
- Erreur avec `DiscList.retry` + `ref.invalidate`
- Vide avec message métier et CTA
- Succès via `AppSnackBar.success`

## Hiérarchie & ergonomie

1. **Un message principal** (titre court).
2. **Une phrase d’explication** (body, `height: 1.35`–`1.45`).
3. **Un CTA primaire** (`AppButton` ou `FilledButton.icon`).
4. Actions secondaires en `TextButton` / lien discret.
5. Carte entière tappable **ou** bouton explicite — pas les deux qui se battent.

## Checklist avant de livrer

- [ ] Couleurs depuis `AppColors` / `colorScheme` (dark + light)
- [ ] Responsive (`madbeauty-responsive`)
- [ ] États async polis (`madbeauty-ux-states`)
- [ ] Textes dans `lib/core/constants/strings/` (pas de chaînes en dur)
- [ ] Réutilisation d’un composant existant quand possible
- [ ] Contraste lisible, CTA visible au premier coup d’œil
- [ ] `dart analyze` OK sur les fichiers modifiés

## Anti-patterns

- UI plate (fond gris + `Icon` seul) sans carte, gradient ni hiérarchie
- Couleurs Material par défaut (`Colors.blue`, `Colors.orange`) hors charte
- Plus de 3 niveaux de texte empilés sans respiration
- Bouton primaire noyé dans le texte
