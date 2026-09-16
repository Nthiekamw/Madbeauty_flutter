import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Variante de fond : app (crème / marron) ou premium (splash / auth).
enum BrandBackgroundVariant {
  app,
  premium,
}

/// Fond décoratif (splash, onboarding, écrans discovery).
class BrandBackground extends StatelessWidget {
  const BrandBackground({
    super.key,
    required this.isDark,
    this.variant = BrandBackgroundVariant.app,
  });

  final bool isDark;
  final BrandBackgroundVariant variant;

  @override
  Widget build(BuildContext context) {
    if (variant == BrandBackgroundVariant.premium) {
      return _PremiumBrandBackground(isDark: isDark);
    }

    final accent = isDark ? AppColors.brandBrownDark : AppColors.brandBrown;
    final wash = accent.withValues(alpha: isDark ? 0.10 : 0.06);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        ),
        if (!kIsWeb)
          Positioned(
            top: -140,
            right: -90,
            child: _Blob(size: 240, color: wash),
          ),
      ],
    );
  }
}

/// Fond splash / auth : plat, sans orbes décoratives.
class _PremiumBrandBackground extends StatelessWidget {
  const _PremiumBrandBackground({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: isDark
          ? AppColors.brandSplashBackground
          : AppColors.lightSurface,
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
