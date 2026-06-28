import 'package:flutter/material.dart';

import 'discovery_responsive.dart';

/// Fond doux + padding horizontal sur shell web (pleine largeur utile).
class WebShellContentFrame extends StatelessWidget {
  const WebShellContentFrame({
    super.key,
    required this.child,
    this.applyHorizontalPadding = true,
  });

  final Widget child;
  final bool applyHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebSiteLayout) return child;

    final theme = Theme.of(context);
    final hPad = applyHorizontalPadding ? layout.webShellHorizontalPadding : 0.0;

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: child,
      ),
    );
  }
}
