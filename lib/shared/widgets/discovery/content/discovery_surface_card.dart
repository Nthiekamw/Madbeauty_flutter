import 'package:flutter/material.dart';

import '../../../layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';

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

    final surfaceColor = AppColors.cardSurfaceFor(theme.brightness);
    const borderRadius = BorderRadius.all(Radius.circular(14));
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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

