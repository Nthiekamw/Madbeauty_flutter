import 'package:flutter/material.dart';

import 'discovery_responsive.dart';

/// Panneau carte pour parcours web (réservation, profil, fiche pro).
class WebFlowPanel extends StatelessWidget {
  const WebFlowPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebSiteLayout) return child;

    final hPad = layout.webFlowHorizontalPadding;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
      child: child,
    );
  }
}
