import 'package:flutter/material.dart';

/// Métriques responsive pour accueil, recherche et cartes prestataires.
class DiscoveryResponsive {
  DiscoveryResponsive._(this.width);

  final double width;

  static DiscoveryResponsive of(BuildContext context) {
    return DiscoveryResponsive._(MediaQuery.sizeOf(context).width);
  }

  static const double compactBreakpoint = 360;
  static const double tabletBreakpoint = 600;
  static const double wideBreakpoint = 900;

  bool get isCompact => width < compactBreakpoint;
  bool get isTablet => width >= tabletBreakpoint;
  bool get isWide => width >= wideBreakpoint;

  double get horizontalPadding => isCompact ? 16 : (isTablet ? 24 : 20);

  /// Largeur utile du contenu (centré sur grands écrans).
  double get contentMaxWidth {
    if (isWide) return 960;
    if (isTablet) return 720;
    return width;
  }

  /// Cartes horizontales accueil : ~2,2 cartes visibles sur téléphone.
  double get homeListCardWidth {
    final inner = width - horizontalPadding * 2;
    if (isTablet) {
      return (inner / 3.2).clamp(168.0, 210.0);
    }
    return (inner / 2.15).clamp(152.0, 188.0);
  }

  double get homeListCardHeight => homeListCardWidth * (232 / 176);

  double get homeListPhotoHeight => homeListCardHeight * (100 / 232);

  /// Colonnes catalogue recherche (toujours 2 colonnes).
  int get catalogGridColumns => 2;

  static const double catalogGridSpacing = 10;

  /// Hauteur d’une tuile grille selon la largeur utile.
  double catalogGridTileHeight() {
    final inner = (contentMaxWidth < width ? contentMaxWidth : width) -
        horizontalPadding * 2;
    final cellW = (inner - catalogGridSpacing) / catalogGridColumns;
    return (cellW * 1.18 + 58).clamp(204.0, 276.0);
  }

  /// Filtres rapides recherche (puces compactes).
  double get quickFiltersStripHeight => 38;

  /// Hauteur max de l’en-tête recherche (titre + barre + filtres rapides).
  double listingTopMaxHeight(double screenHeight) =>
      screenHeight * (isCompact ? 0.26 : 0.28);

  /// Hauteur max du panneau filtres avancés (replié ≈ 100–110 px).
  double listingFiltersMaxHeight(double screenHeight, {required bool expanded}) {
    if (!expanded) return 118;
    return screenHeight * (isCompact ? 0.22 : 0.26);
  }

  /// Aperçu accueil : limite d’éléments scrollables (le reste via « Tout voir »).
  int get homeHorizontalPreviewLimit => isTablet ? 20 : 16;

  /// Formulaires (profil, devenir prestataire, édition compte).
  double get formMaxWidth => contentMaxWidth;

  EdgeInsets get formPadding =>
      EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 28);

  /// Champs côte à côte (ex. CP + ville, cartes rôle).
  bool get useSideBySideFormRows => width >= 400;

  /// Cartes client / prestataire empilées sur petit écran.
  bool get stackRoleSpaceCards => width < 400;

  /// Boutons Continuer / Retour du stepper empilés.
  bool get stackStepperActions => isCompact;
}
