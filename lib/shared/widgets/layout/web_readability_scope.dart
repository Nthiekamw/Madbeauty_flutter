import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../layout/discovery_responsive.dart';
import '../../layout/web_readability.dart';

/// Applique échelle texte + icônes sur Flutter Web.
class WebReadabilityScope extends StatelessWidget {
  const WebReadabilityScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    final media = MediaQuery.of(context);
    final width = media.size.width;
    // Web mobile : même densité typographique que l'app native.
    if (width < DiscoveryResponsive.tabletBreakpoint) return child;
    final textScale = WebReadability.textScaleFactor(width);
    final iconScale = WebReadability.iconScaleFactor(width);
    final baseIconSize = IconTheme.of(context).size ?? 24;

    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: IconTheme(
        data: IconTheme.of(context).copyWith(
          size: baseIconSize * iconScale,
        ),
        child: child,
      ),
    );
  }
}
