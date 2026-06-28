import 'package:flutter/material.dart';

import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/discovery_styles.dart';

/// Carte surface alignée sur les listes de l'accueil client.
abstract final class PrestataireDetailSurface {
  PrestataireDetailSurface._();

  static BoxDecoration cardDecoration(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final layout = DiscoveryResponsive.of(context);
    final radius = layout.useWebSiteLayout
        ? layout.webShellCardRadius
        : DiscoveryStyles.cardBorderRadius.topLeft.x;

    return BoxDecoration(
      color: AppColors.cardSurfaceFor(theme.brightness),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: theme.colorScheme.outline.withValues(
          alpha: isDark ? 0.28 : 0.08,
        ),
      ),
      boxShadow: isDark
          ? null
          : [
              BoxShadow(
                color: AppColors.brandBrown.withValues(
                  alpha: layout.useWebSiteLayout ? 0.07 : 0.08,
                ),
                blurRadius: layout.useWebSiteLayout ? 18 : 10,
                offset: Offset(0, layout.useWebSiteLayout ? 6 : 3),
              ),
            ],
    );
  }

  static Material cardMaterial({
    required BuildContext context,
    required ThemeData theme,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    final layout = DiscoveryResponsive.of(context);
    final radius = BorderRadius.circular(
      layout.useWebSiteLayout
          ? layout.webShellCardRadius
          : DiscoveryStyles.cardBorderRadius.topLeft.x,
    );
    final decoration = cardDecoration(context, theme);

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
