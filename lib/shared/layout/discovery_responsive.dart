import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Métriques responsive pour accueil, recherche et cartes prestataires.
class DiscoveryResponsive {
  DiscoveryResponsive._({
    required this.width,
    required this.viewportWidth,
  });

  /// Largeur du parent (colonne contenu si le shell web la borne).
  final double width;

  /// Largeur de la fenêtre (rail, mode site) — indépendante de la colonne.
  final double viewportWidth;

  static DiscoveryResponsive of(BuildContext context) {
    final view = View.of(context);
    final viewportWidth = view.physicalSize.width / view.devicePixelRatio;
    return DiscoveryResponsive._(
      width: MediaQuery.sizeOf(context).width,
      viewportWidth: viewportWidth,
    );
  }

  static const double compactBreakpoint = 360;
  static const double tabletBreakpoint = 600;
  static const double wideBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  bool get isCompact => width < compactBreakpoint;
  bool get isTablet => viewportWidth >= tabletBreakpoint;
  bool get isWide => viewportWidth >= wideBreakpoint;
  bool get isDesktop => viewportWidth >= desktopBreakpoint;

  /// Web tablette / desktop (≥ 600 px) : navigation et auth type « site ».
  bool get useWebSiteLayout => kIsWeb && viewportWidth >= tabletBreakpoint;

  /// Web téléphone ou app native : même expérience que l'app mobile.
  bool get useNativeMobileExperience =>
      !kIsWeb || viewportWidth < tabletBreakpoint;

  /// Navigation latérale (Flutter Web tablette+).
  bool get useSidebarNavigation => useWebSiteLayout;

  /// Conservé pour compatibilité — le web mobile utilise la bottom nav native.
  bool get useWebTopNavigation => false;

  double get horizontalPadding {
    if (useSidebarNavigation) return 32;
    return isCompact ? 16 : (isTablet ? 24 : 20);
  }

  /// Largeur utile du contenu (centré sur grands écrans).
  double get contentMaxWidth {
    if (useWebSiteLayout) return webShellContentMaxWidth;
    if (isWide) return 1080;
    if (isTablet) return 720;
    return width;
  }

  static const double homeListCardGap = 8;

  /// Cartes horizontales accueil : 3 cartes visibles sur téléphone.
  double get homeListCardWidth {
    final pad = useSidebarNavigation
        ? webShellHorizontalPadding
        : horizontalPadding;
    final inner = width - pad * 2;
    if (kIsWeb && isDesktop) {
      return (inner / 4.8).clamp(148.0, 220.0);
    }
    if (isTablet) {
      return (inner / 3.8).clamp(148.0, 188.0);
    }
    return ((inner - homeListCardGap * 2) / 3).clamp(98.0, 130.0);
  }

  double get homeListCardHeight {
    final ratio = useWebSiteLayout && isTablet
        ? 1.56
        : isCompact
            ? 1.56
            : 1.48;
    return homeListCardWidth * ratio;
  }

  /// Part photo / texte : réserve une zone texte lisible sous l'image.
  double homeListPhotoHeightFor(double cardHeight) {
    final minText = homeListMinTextZoneHeight;
    final maxPhoto = cardHeight - minText - 8;
    final preferred = cardHeight * (isCompact ? 0.58 : 0.66);
    return preferred.clamp(cardHeight * 0.52, maxPhoto);
  }

  double get homeListMinTextZoneHeight {
    if (useWebSiteLayout && isWide) return 52;
    if (isTablet) return 48;
    return isCompact ? 50 : 44;
  }

  double homeListTitleFontSize(double cardWidth) =>
      (cardWidth * 0.092).clamp(11.0, 15.0);

  double homeListBodyFontSize(double cardWidth) =>
      (cardWidth * 0.078).clamp(10.0, 13.0);

  /// Cartes portrait « Tendances cette semaine » (plus grandes que la grille accueil).
  double get homeTrendingCardWidth {
    const gap = 12.0;
    final pad = useSidebarNavigation
        ? webShellHorizontalPadding
        : horizontalPadding;
    final inner = width - pad * 2;
    if (useWebSiteLayout) {
      if (isDesktop) return ((inner - gap * 3) / 4.2).clamp(168.0, 260.0);
      if (isWide) return ((inner - gap * 2) / 3.5).clamp(164.0, 230.0);
      return ((inner - gap * 2) / 3.2).clamp(160.0, 210.0);
    }
    if (isTablet) {
      return ((inner - gap * 2) / 3.0).clamp(156.0, 200.0);
    }
    // ~2 cartes visibles sur téléphone pour un format portrait plus lisible.
    return ((inner - gap) / 2.15).clamp(148.0, 172.0);
  }

  double get homeTrendingCardHeight => homeTrendingCardWidth * 1.52;

  double homeTrendingTitleFontSize(double cardWidth) =>
      (cardWidth * 0.075).clamp(11.0, 14.0);

  double homeTrendingBodyFontSize(double cardWidth) =>
      (cardWidth * 0.065).clamp(9.5, 12.0);

  static const double homeTrendingCardGap = 12;

  @Deprecated('Use homeListPhotoHeightFor(cardHeight)')
  double get homeListPhotoHeight => homeListCardHeight * 0.68;

  static const double homePromoBannerAspectWidth = 1024;
  static const double homePromoBannerAspectHeight = 682;

  /// Marge souhaitée entre la bannière promo et le bord de l’écran.
  @Deprecated('La bannière suit la largeur du parent (colonne).')
  double get homePromoBannerOuterMargin {
    if (useSidebarNavigation) return 20;
    if (isCompact) return 10;
    if (isTablet) return 12;
    return 12;
  }

  /// Hero promo (texte + mosaïque, hauteur bornée).
  ({double width, double height}) homePromoBannerDimensions(
    double parentWidth, {
    required double horizontalPadding,
  }) {
    final width = parentWidth;
    var height = width *
        homePromoBannerAspectHeight /
        homePromoBannerAspectWidth;

    if (useNativeMobileExperience) {
      height = height.clamp(220, 288);
    } else if (isDesktop) {
      height = height.clamp(220, 268);
    } else {
      height = height.clamp(210, 248);
    }

    return (width: width, height: height);
  }

  /// @deprecated Utiliser [homePromoBannerDimensions].
  @Deprecated('Use homePromoBannerDimensions(parentWidth, horizontalPadding: pad)')
  double homePromoBannerHeight(double bannerWidth) {
    return homePromoBannerDimensions(
      bannerWidth,
      horizontalPadding: 0,
    ).height;
  }

  /// Colonnes catalogue en mode grille.
  int get catalogGridColumns {
    if (useWebSiteLayout) {
      if (isDesktop) return 4;
      if (isWide || width >= 720) return 3;
      return 2;
    }
    if (isWide) return 3;
    return 2;
  }

  static const double catalogGridSpacing = 10;

  /// Espacement grille catalogue (plus aéré sur web).
  double get catalogGridGap =>
      useWebSiteLayout ? 16 : catalogGridSpacing;

  /// Largeur d'une cellule grille catalogue (colonnes adaptatives).
  double catalogGridCellWidth({double horizontalInset = 0}) {
    final cols = catalogGridColumns;
    final innerWidth = useWebSiteLayout
        ? width
        : (contentMaxWidth < width ? contentMaxWidth : width);
    final inner = (innerWidth - horizontalInset).clamp(80.0, innerWidth);
    final gap = catalogGridGap;
    return (inner - gap * (cols - 1)) / cols;
  }

  /// Hauteur d'une tuile grille catalogue (ratio carte / largeur).
  double catalogGridTileHeight({double horizontalInset = 0}) =>
      catalogGridCellWidth(horizontalInset: horizontalInset) * 1.68;

  /// Photo grille : ~78 % de la hauteur carte (texte compact en bas).
  double catalogGridPhotoHeight({double horizontalInset = 0}) =>
      catalogGridTileHeight(horizontalInset: horizontalInset) * 0.78;

  /// Filtres rapides recherche (puces compactes).
  double get quickFiltersStripHeight => 34;

  /// Hauteur max de l'en-tête recherche (titre + barre + filtres rapides).
  double listingTopMaxHeight(double screenHeight) =>
      screenHeight * (isCompact ? 0.26 : 0.28);

  /// Hauteur max du panneau filtres avancés (replié â‰ˆ 100—110 px).
  double listingFiltersMaxHeight(double screenHeight, {required bool expanded}) {
    if (!expanded) return 118;
    return screenHeight * (isCompact ? 0.22 : 0.26);
  }

  /// Aperçu accueil : limite d'éléments scrollables (le reste via « Tout voir »).
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

  /// Connexion / inscription centrés : web tablette+ uniquement.
  bool get useWebAuthFormLayout => useWebSiteLayout;

  /// Deux colonnes (profil, cockpit) : occupe l’écran sans étirer une liste.
  bool get useWebTwoPane => useWebSiteLayout && width >= 840;

  /// Largeur max contenu shell web (Accueil, Catalogue, etc.).
  double get webShellContentMaxWidth {
    if (isDesktop) return 1320;
    if (isWide) return 1140;
    return 960;
  }

  /// Padding horizontal contenu shell web.
  double get webShellHorizontalPadding {
    if (isDesktop) return 40;
    if (isWide) return 32;
    return 24;
  }

  /// Padding vertical haut des pages shell web.
  double get webShellTopPadding => isDesktop ? 28 : 22;

  /// Rayons cartes shell web.
  double get webShellCardRadius => 4;

  /// Colonne max parcours web (fiche prestataire, réservation).
  double get webFlowContentMaxWidth {
    if (!useWebSiteLayout) return width;
    if (isDesktop) return 1120;
    if (isWide) return 960;
    return 820;
  }

  /// Padding horizontal parcours web (fiche, réservation).
  double get webFlowHorizontalPadding {
    if (isDesktop) return 28;
    if (isWide) return 24;
    return 20;
  }

  /// Padding horizontal page (shell ou parcours).
  double pageHorizontalPadding({bool flow = false}) {
    if (useWebSiteLayout) {
      return flow ? webFlowHorizontalPadding : webShellHorizontalPadding;
    }
    return horizontalPadding;
  }

  /// Largeur max des formulaires auth (connexion, inscription, etc.).
  double authFormMaxWidthFor(double parentWidth) {
    if (useNativeMobileExperience) return parentWidth;
    final cap = switch (width) {
      >= desktopBreakpoint => 480.0,
      >= wideBreakpoint => 460.0,
      >= tabletBreakpoint => 440.0,
      _ => 400.0,
    };
    return cap.clamp(280.0, parentWidth);
  }
}

