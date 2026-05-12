import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Squelette pour liste verticale du catalogue (écran listing).
class ListingVerticalSkeleton extends StatelessWidget {
  const ListingVerticalSkeleton({super.key, this.rowCount = 8});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = Color.lerp(
          base,
          theme.colorScheme.surface,
          theme.brightness == Brightness.dark ? 0.4 : 0.65,
        ) ??
        base;
    final track = theme.colorScheme.onSurface.withValues(alpha: 0.08);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      period: const Duration(milliseconds: 1200),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: rowCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return Container(
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: track,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: track,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 12,
                        width: 160,
                        decoration: BoxDecoration(
                          color: track,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: track,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
