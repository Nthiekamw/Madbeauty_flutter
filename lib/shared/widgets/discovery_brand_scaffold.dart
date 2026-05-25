import 'package:flutter/material.dart';

import '../theme/prototype_palette.dart';
import 'brand_background.dart';

/// Corps d’écran client avec fond brand (sans AppBar).
class DiscoveryBrandScaffold extends StatelessWidget {
  const DiscoveryBrandScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
  });

  final Widget body;

  /// Fond crème plat (style Madbeauty_flutter) ; null = crème client par défaut en light.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cream = backgroundColor ??
        (isDark ? null : PrototypePalette.creamClient);

    return Scaffold(
      backgroundColor: cream,
      body: cream == null
          ? Stack(
              fit: StackFit.expand,
              children: [
                BrandBackground(isDark: isDark),
                SafeArea(child: body),
              ],
            )
          : SafeArea(child: body),
    );
  }
}
