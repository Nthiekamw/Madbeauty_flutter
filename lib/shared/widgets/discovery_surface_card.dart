import 'package:flutter/material.dart';

import '../theme/discovery_styles.dart';

/// Carte surface semi-opaque sur fond brand.
class DiscoverySurfaceCard extends StatelessWidget {
  const DiscoverySurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(
            alpha: isDark ? 0.92 : 0.98,
          ),
          borderRadius: DiscoveryStyles.cardBorderRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
