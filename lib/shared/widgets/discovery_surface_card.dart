import 'package:flutter/material.dart';

import '../theme/prototype_palette.dart';

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
          color: isDark
              ? theme.colorScheme.surface.withValues(alpha: 0.92)
              : PrototypePalette.cardWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.outline.withValues(alpha: 0.12)
                : PrototypePalette.goldLight.withValues(alpha: 0.5),
          ),
          boxShadow: isDark ? null : PrototypePalette.cardShadow(),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
