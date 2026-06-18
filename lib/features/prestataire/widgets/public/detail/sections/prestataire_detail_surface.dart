import 'package:flutter/material.dart';

import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/discovery_styles.dart';

/// Carte surface alignée sur les listes de l'accueil client.
abstract final class PrestataireDetailSurface {
  PrestataireDetailSurface._();

  static BoxDecoration cardDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return BoxDecoration(
      color: AppColors.cardSurfaceFor(theme.brightness),
      borderRadius: DiscoveryStyles.cardBorderRadius,
      border: Border.all(
        color: theme.colorScheme.outline.withValues(
          alpha: isDark ? 0.28 : 0.08,
        ),
      ),
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: AppColors.brandBrown.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
    );
  }

  static Material cardMaterial({
    required ThemeData theme,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    final radius = DiscoveryStyles.cardBorderRadius;
    final decoration = cardDecoration(theme);

    Widget content = Ink(
      decoration: decoration,
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      content = Material(
        color: AppColors.transparent,
        child: InkWell(onTap: onTap, borderRadius: radius, child: content),
      );
    }

    return Material(
      color: AppColors.transparent,
      elevation: theme.brightness == Brightness.dark ? 0 : 1,
      shadowColor: AppColors.brandBrown.withValues(alpha: 0.08),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
