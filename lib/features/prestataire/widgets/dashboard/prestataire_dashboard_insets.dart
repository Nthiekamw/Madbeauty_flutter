import 'package:flutter/material.dart';

import '../../../../shared/layout/discovery_responsive.dart';

/// Marges horizontales unifiées du dashboard prestataire.
abstract final class PrestataireDashboardInsets {
  PrestataireDashboardInsets._();

  static double horizontal(BuildContext context) =>
      DiscoveryResponsive.of(context).horizontalPadding;

  static EdgeInsets page(BuildContext context) => EdgeInsets.fromLTRB(
        horizontal(context),
        0,
        horizontal(context),
        0,
      );

  static EdgeInsets section(BuildContext context) => EdgeInsets.fromLTRB(
        horizontal(context),
        0,
        horizontal(context),
        10,
      );
}
