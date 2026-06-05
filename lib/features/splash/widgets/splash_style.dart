import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Couleurs du splash dérivées du thème système (clair / sombre).
@immutable
class SplashStyle {
  const SplashStyle({
    required this.isDark,
    required this.titleColor,
    required this.taglineColor,
    required this.statusColor,
    required this.indicatorColor,
    required this.glowColor,
  });

  factory SplashStyle.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    if (isDark) {
      return SplashStyle(
        isDark: true,
        titleColor: AppColors.brandGoldLight,
        taglineColor: AppColors.brandGoldLight.withValues(alpha: 0.88),
        statusColor: AppColors.brandGoldLight.withValues(alpha: 0.82),
        indicatorColor: AppColors.brandGold,
        glowColor: AppColors.brandGoldGlow20,
      );
    }

    return SplashStyle(
      isDark: false,
      titleColor: AppColors.brandBrown,
      taglineColor: scheme.onSurfaceVariant,
      statusColor: AppColors.lightOnSurfaceVariant,
      indicatorColor: AppColors.brandGoldDark,
      glowColor: AppColors.brandGold.withValues(alpha: 0.38),
    );
  }

  final bool isDark;
  final Color titleColor;
  final Color taglineColor;
  final Color statusColor;
  final Color indicatorColor;
  final Color glowColor;
}
