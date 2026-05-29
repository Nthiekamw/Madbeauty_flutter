import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Fond décoratif marron / crème (splash, onboarding, bienvenue).
class BrandBackground extends StatelessWidget {
  const BrandBackground({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
