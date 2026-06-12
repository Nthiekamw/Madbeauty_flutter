import 'package:flutter/material.dart';

import '../../../../shared/widgets/discovery/content/discovery_shimmer.dart';

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
    final track = DiscoveryShimmer.colors(theme).track;

    return SizedBox(
      height: height,
      child: DiscoveryShimmer.wrap(
        context: context,
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
