import 'package:flutter/material.dart';

import '../../layout/brand_background.dart';
import '../../../layout/discovery_responsive.dart';

/// Corps d'écran client avec fond brand (sans AppBar).
class DiscoveryBrandScaffold extends StatelessWidget {
  const DiscoveryBrandScaffold({
    super.key,
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    if (DiscoveryResponsive.of(context).useWebSiteLayout) {
      return Scaffold(
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerLowest,
        body: body,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          BrandBackground(isDark: isDark),
          SafeArea(child: body),
        ],
      ),
    );
  }
}

