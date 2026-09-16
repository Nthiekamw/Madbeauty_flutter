import 'package:flutter/material.dart';

import 'discovery_responsive.dart';

/// Fond doux + colonne centrée (évite d’étirer le contenu sur grand écran).
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
    final hPad =
        applyHorizontalPadding ? layout.webShellHorizontalPadding : 0.0;

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: WebCenteredContent(
          maxWidth: layout.webShellContentMaxWidth,
          child: child,
        ),
      ),
    );
  }
}

/// Centre [child] et aligne [MediaQuery.size.width] sur la colonne réelle.
class WebCenteredContent extends StatelessWidget {
  const WebCenteredContent({
    super.key,
    required this.maxWidth,
    required this.child,
  });

  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            final w = constraints.maxWidth;
            if (!w.isFinite || w <= 0 || (w - mq.size.width).abs() < 0.5) {
              return child;
            }
            return MediaQuery(
              data: mq.copyWith(size: Size(w, mq.size.height)),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
