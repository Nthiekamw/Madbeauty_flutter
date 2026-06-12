import 'package:flutter/material.dart';

import '../../../theme/discovery_styles.dart';
import 'discovery_shimmer.dart';

/// Squelette pleine page pour fiches / détails (réservation, profil…).
class DiscoveryDetailSkeleton extends StatelessWidget {
  const DiscoveryDetailSkeleton({
    super.key,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final track = DiscoveryShimmer.colors(theme).track;
    final radius = DiscoveryStyles.cardBorderRadius;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      child: DiscoveryShimmer.wrap(
        context: context,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 22,
              width: 180,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: radius,
              ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < 4; i++) ...[
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
