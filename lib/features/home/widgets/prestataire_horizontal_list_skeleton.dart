import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Squelette de la liste horizontale prestataires (accueil : proches, mieux notés).
class PrestataireHorizontalListSkeleton extends StatelessWidget {
  const PrestataireHorizontalListSkeleton({
    super.key,
    this.itemCount = 5,
    this.height = 172,
    this.cardWidth = 168,
  });

  final int itemCount;
  final double height;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.colorScheme.surfaceContainerHigh;
    final track = theme.colorScheme.onSurface.withValues(alpha: 0.08);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = Color.lerp(
          base,
          theme.colorScheme.surface,
          theme.brightness == Brightness.dark ? 0.4 : 0.65,
        ) ??
        base;

    return SizedBox(
      height: height,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        period: const Duration(milliseconds: 1200),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: cardBg,
                child: SizedBox(
                  width: cardWidth,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: track,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 12,
                                decoration: BoxDecoration(
                                  color: track,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 14,
                          width: cardWidth * 0.72,
                          decoration: BoxDecoration(
                            color: track,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: cardWidth * 0.45,
                          decoration: BoxDecoration(
                            color: track,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 10,
                          width: 56,
                          decoration: BoxDecoration(
                            color: track,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
