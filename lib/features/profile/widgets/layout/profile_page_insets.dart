import 'package:flutter/material.dart';

import '../../../../shared/layout/discovery_responsive.dart';

/// Marges horizontales et espacement vertical unifiés sur l'écran profil.
abstract final class ProfilePageInsets {
  static const sectionGap = 16.0;

  static double horizontal(BuildContext context) =>
      DiscoveryResponsive.of(context).horizontalPadding;

  static EdgeInsets page(BuildContext context) => EdgeInsets.fromLTRB(
        horizontal(context),
        16,
        horizontal(context),
        0,
      );
}
