import 'package:flutter/material.dart';

import 'brand_background.dart';

/// Fond auth / onboarding : suit le mode clair / sombre du système.
class AuthBrandBackground extends StatelessWidget {
  const AuthBrandBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BrandBackground(
      isDark: isDark,
      variant: BrandBackgroundVariant.premium,
    );
  }
}
