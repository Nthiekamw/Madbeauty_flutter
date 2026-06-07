import 'package:flutter/material.dart';

import '../../layout/discovery_responsive.dart';
import '../../theme/discovery_styles.dart';
import '../../../shared/theme/app_colors.dart';

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

    final surfaceColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : theme.colorScheme.surface.withValues(alpha: 0.98);
    final borderRadius = DiscoveryStyles.cardBorderRadius;
    final borderSide = BorderSide(
      color: theme.colorScheme.outline.withValues(alpha: 0.12),
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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

