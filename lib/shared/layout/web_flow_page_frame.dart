import 'package:flutter/material.dart';

import 'discovery_responsive.dart';

/// Colonne centrée pour parcours (fiche prestataire, réservation) sur web.
class WebFlowPageFrame extends StatelessWidget {
  const WebFlowPageFrame({
    super.key,
    required this.child,
    this.applyBackground = true,
  });

  final Widget child;
  final bool applyBackground;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebSiteLayout) return child;

    final theme = Theme.of(context);
    final framed = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: layout.webFlowContentMaxWidth),
        child: child,
      ),
    );

    if (!applyBackground) return framed;

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLowest,
      child: framed,
    );
  }
}
