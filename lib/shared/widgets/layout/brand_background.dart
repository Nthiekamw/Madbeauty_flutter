import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Variante de fond : app (crème / marron) ou premium (noir / or, logo).
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
    final wash = accent.withValues(alpha: isDark ? 0.12 : 0.08);
    final washSoft = accent.withValues(alpha: isDark ? 0.06 : 0.04);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _Blob(size: 280, color: wash),
        ),
        Positioned(
          top: 140,
          left: -100,
          child: _Blob(size: 220, color: washSoft),
        ),
        Positioned(
          bottom: -60,
          left: -40,
          child: _Blob(size: 200, color: wash),
        ),
        Positioned(
          bottom: 120,
          right: -30,
          child: _Blob(size: 140, color: washSoft),
        ),
      ],
    );
  }
}

/// Fond splash / auth marketing : noir + or (sombre) ou crème + or (clair).
class _PremiumBrandBackground extends StatelessWidget {
  const _PremiumBrandBackground({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!isDark) {
      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.lightSurface),
          Positioned(
            top: -100,
            right: -60,
            child: _Blob(
              size: 260,
              color: AppColors.brandGold.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            top: 160,
            left: -90,
            child: _Blob(
              size: 200,
              color: AppColors.brandBrown.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -50,
            child: _Blob(
              size: 180,
              color: AppColors.brandGold.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -20,
            child: _Blob(
              size: 120,
              color: AppColors.brownSecondaryLight.withValues(alpha: 0.12),
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.brandSplashBackground),
        Positioned(
          top: -100,
          right: -60,
          child: _Blob(size: 260, color: AppColors.brandGoldGlow12),
        ),
        Positioned(
          top: 160,
          left: -90,
          child: _Blob(size: 200, color: AppColors.brandGoldGlow20),
        ),
        Positioned(
          bottom: -40,
          left: -50,
          child: _Blob(size: 180, color: AppColors.brandGoldGlow12),
        ),
        Positioned(
          bottom: 100,
          right: -20,
          child: _Blob(size: 120, color: AppColors.brandGoldGlow20),
        ),
      ],
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
