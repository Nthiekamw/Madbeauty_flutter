import 'package:flutter/material.dart';

import 'brand_background.dart';

/// Corps d’écran client avec fond brand (sans AppBar).
class DiscoveryBrandScaffold extends StatelessWidget {
  const DiscoveryBrandScaffold({
    super.key,
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
