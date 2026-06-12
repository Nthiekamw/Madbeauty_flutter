import 'package:flutter/material.dart';

import '../../../theme/discovery_styles.dart';
import 'discovery_shimmer.dart';

/// Squelette liste verticale (réservations, favoris, catalogue…).
class DiscoveryListSkeleton extends StatelessWidget {
  const DiscoveryListSkeleton({
    super.key,
    this.rowCount = 6,
    this.rowHeight = 100,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
    this.borderRadius,
  });

  final int rowCount;
  final double rowHeight;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  /// Variante [Sliver] pour [CustomScrollView] (évite ListView shrinkWrap).
  static Widget asSliver({
    int rowCount = 6,
    double rowHeight = 100,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
    BorderRadius? borderRadius,
  }) {
    return _DiscoveryListSkeletonSliver(
      rowCount: rowCount,
      rowHeight: rowHeight,
      padding: padding,
      borderRadius: borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius =
        borderRadius ?? DiscoveryStyles.catalogListCardBorderRadius;

    return Padding(
      padding: padding,
      child: DiscoveryShimmer.wrap(
        context: context,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final rows = _skeletonRows(
              context: context,
              theme: theme,
              rowCount: rowCount,
              rowHeight: rowHeight,
              borderRadius: radius,
            );

            // Parent à hauteur bornée (Expanded, SizedBox…) : scroll interne.
            if (constraints.hasBoundedHeight) {
              return ListView(
                physics: const ClampingScrollPhysics(),
                children: rows,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: rows,
            );
          },
        ),
      ),
    );
  }

  static List<Widget> _skeletonRows({
    required BuildContext context,
    required ThemeData theme,
    required int rowCount,
    required double rowHeight,
    required BorderRadius borderRadius,
  }) {
    final trackColor = DiscoveryShimmer.colors(theme).track;
    final rows = <Widget>[];
    for (var i = 0; i < rowCount; i++) {
      if (i > 0) rows.add(const SizedBox(height: 12));
      rows.add(
        _SkeletonRow(
          rowHeight: rowHeight,
          borderRadius: borderRadius,
          surfaceColor: theme.colorScheme.surfaceContainerHigh,
          trackColor: trackColor,
        ),
      );
    }
    return rows;
  }
}

class _DiscoveryListSkeletonSliver extends StatelessWidget {
  const _DiscoveryListSkeletonSliver({
    required this.rowCount,
    required this.rowHeight,
    required this.padding,
    this.borderRadius,
  });

  final int rowCount;
  final double rowHeight;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius =
        borderRadius ?? DiscoveryStyles.catalogListCardBorderRadius;

    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: DiscoveryShimmer.wrap(
          context: context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: DiscoveryListSkeleton._skeletonRows(
              context: context,
              theme: theme,
              rowCount: rowCount,
              rowHeight: rowHeight,
              borderRadius: radius,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const _SkeletonRow({
    required this.rowHeight,
    required this.borderRadius,
    required this.surfaceColor,
    required this.trackColor,
  });

  final double rowHeight;
  final BorderRadius borderRadius;
  final Color surfaceColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final compact = rowHeight < 88;
    final padding = compact ? 8.0 : 12.0;
    final innerHeight = rowHeight - padding * 2;
    final avatarSize = innerHeight.clamp(24.0, 56.0);

    Widget line({required double height, required double width}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(4),
        ),
      );
    }

    return Container(
      height: rowHeight,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: borderRadius,
      ),
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: trackColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxH = constraints.maxHeight;
                if (!maxH.isFinite || maxH <= 0) {
                  return const SizedBox.shrink();
                }

                var lineHeight = compact ? 12.0 : 16.0;
                var gap = compact ? 6.0 : 10.0;
                var lineCount = 1;

                bool fits(int count) {
                  if (count <= 0) return true;
                  return count * lineHeight + (count - 1) * gap <= maxH;
                }

                if (fits(2)) lineCount = 2;
                if (!compact && fits(3)) lineCount = 3;

                while (lineCount > 1 && !fits(lineCount)) {
                  lineCount--;
                }
                while (!fits(lineCount) && lineHeight > 8) {
                  lineHeight -= 1;
                }
                while (!fits(lineCount) && gap > 2) {
                  gap -= 1;
                }
                if (!fits(lineCount)) {
                  lineCount = 1;
                  lineHeight = maxH.clamp(8.0, lineHeight);
                }

                final widths = <double>[double.infinity, 160.0, 120.0];
                final children = <Widget>[];
                for (var i = 0; i < lineCount; i++) {
                  if (i > 0) children.add(SizedBox(height: gap));
                  children.add(
                    line(height: lineHeight, width: widths[i]),
                  );
                }

                return ClipRect(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
