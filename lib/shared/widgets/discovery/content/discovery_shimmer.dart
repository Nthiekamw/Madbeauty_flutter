import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Couleurs shimmer cohérentes avec le thème MadBeauty.
abstract final class DiscoveryShimmer {
  DiscoveryShimmer._();

  static ({Color base, Color highlight, Color track}) colors(ThemeData theme) {
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = Color.lerp(
          base,
          theme.colorScheme.surface,
          theme.brightness == Brightness.dark ? 0.4 : 0.65,
        ) ??
        base;
    final track = theme.colorScheme.onSurface.withValues(alpha: 0.08);
    return (base: base, highlight: highlight, track: track);
  }

  static Widget wrap({
    required BuildContext context,
    required Widget child,
  }) {
    final c = colors(Theme.of(context));
    return Shimmer.fromColors(
      baseColor: c.base,
      highlightColor: c.highlight,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// Rectangle shimmer réutilisable.
class DiscoveryShimmerBox extends StatelessWidget {
  const DiscoveryShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final track = DiscoveryShimmer.colors(Theme.of(context)).track;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: track,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Bandeau shimmer compact pour sections embarquées (checkout, plans, cartes…).
class DiscoveryInlineSkeleton extends StatelessWidget {
  const DiscoveryInlineSkeleton({
    super.key,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.borderRadius = 8,
  });

  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final track = DiscoveryShimmer.colors(Theme.of(context)).track;
    return Padding(
      padding: padding,
      child: DiscoveryShimmer.wrap(
        context: context,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
