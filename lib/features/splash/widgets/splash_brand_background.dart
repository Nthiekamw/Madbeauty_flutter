import 'package:flutter/material.dart';

import '../../../shared/widgets/layout/brand_background.dart';

/// Fond splash : suit le mode clair / sombre du système.
class SplashBrandBackground extends StatelessWidget {
  const SplashBrandBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BrandBackground(
      isDark: isDark,
      variant: BrandBackgroundVariant.premium,
    );
  }
}
