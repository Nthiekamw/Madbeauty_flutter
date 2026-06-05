import 'package:flutter/material.dart';

import '../../../../../shared/layout/discovery_responsive.dart';

/// Marges et espacements unifiés — écran profil prestataire.
abstract final class PrestataireProfileInsets {
  PrestataireProfileInsets._();

  static double horizontal(BuildContext context) =>
      DiscoveryResponsive.of(context).horizontalPadding;

  static const sectionTop = 20.0;
  static const itemGap = 10.0;
  static const titleBottom = 10.0;

  /// Marge bas de liste (barre d’onglets + safe area).
  static double listBottom(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom + 88;
  }

  static EdgeInsets page(BuildContext context) => EdgeInsets.fromLTRB(
        horizontal(context),
        0,
        horizontal(context),
        0,
      );
}
