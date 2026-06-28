import 'package:flutter/material.dart';

import '../../../layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';

/// Rayons, bordures et ombres cohérents pour cartes liste / tuiles.
abstract final class DiscoveryCardChrome {
  static double radius(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    return layout.useWebSiteLayout ? layout.webShellCardRadius : 14;
  }

  static BorderSide borderSide(ThemeData theme, {bool emphasized = false}) {
    final isDark = theme.brightness == Brightness.dark;
    return BorderSide(
      color: theme.colorScheme.outline.withValues(
        alpha: isDark ? 0.28 : (emphasized ? 0.14 : 0.1),
      ),
    );
  }

  static List<BoxShadow>? elevationShadow(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final theme = Theme.of(context);
    if (theme.brightness == Brightness.dark) return null;

    if (layout.useWebSiteLayout) {
      return [
        BoxShadow(
          color: AppColors.brandBrown.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
    }

    return [
      BoxShadow(
        color: theme.colorScheme.primary.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ];
  }
}

/// Carte surface semi-opaque sur fond brand.
class DiscoverySurfaceCard extends StatelessWidget {
  const DiscoverySurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.includeHorizontalMargin = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool includeHorizontalMargin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final layout = DiscoveryResponsive.of(context);

    final surfaceColor = AppColors.cardSurfaceFor(theme.brightness);
    final borderRadius = BorderRadius.circular(
      layout.useWebSiteLayout ? layout.webShellCardRadius : 14,
    );
    final borderSide = BorderSide(
      color: theme.colorScheme.outline.withValues(
        alpha: isDark ? 0.28 : 0.1,
      ),
    );

    final card = Material(
      color: surfaceColor,
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: borderSide,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    final cardWithShadow = isDark
        ? card
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(
                    alpha: layout.useWebSiteLayout ? 0.07 : 0.04,
                  ),
                  blurRadius: layout.useWebSiteLayout ? 18 : 10,
                  offset: Offset(0, layout.useWebSiteLayout ? 6 : 3),
                ),
              ],
            ),
            child: card,
          );

    if (!includeHorizontalMargin) return cardWithShadow;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: cardWithShadow,
    );
  }
}

