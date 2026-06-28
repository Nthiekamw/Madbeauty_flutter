import 'package:flutter/material.dart';

import 'discovery_responsive.dart';

/// [SafeArea] sur mobile natif ; contenu plein cadre sur web desktop.
class AdaptiveSafeArea extends StatelessWidget {
  const AdaptiveSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
  });

  final Widget child;
  final bool top;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    if (DiscoveryResponsive.of(context).useWebSiteLayout) {
      return child;
    }

    return SafeArea(
      top: top,
      bottom: bottom,
      child: child,
    );
  }
}
