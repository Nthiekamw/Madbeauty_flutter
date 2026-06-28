import 'package:flutter/material.dart';

import '../../../../shared/layout/discovery_responsive.dart';

/// Marges horizontales et espacement vertical unifiés sur l'écran profil.
abstract final class ProfilePageInsets {
  static const sectionGap = 16.0;

  static double horizontal(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (layout.useWebSiteLayout) return layout.webShellHorizontalPadding;
    return layout.horizontalPadding;
  }

  static EdgeInsets page(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final top = layout.useWebSiteLayout ? 20.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal(context), top, horizontal(context), 0);
  }
}
