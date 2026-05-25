import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import 'prestataire_metric_tile.dart';

class PrestataireDashboardStatsStrip extends StatelessWidget {
  const PrestataireDashboardStatsStrip({
    super.key,
    required this.pendingCount,
    required this.todayCount,
    required this.weekCount,
  });

  final int pendingCount;
  final int todayCount;
  final int weekCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PrestataireMetricStrip(
      metrics: [
        PrestataireMetricTile(
          icon: Icons.inbox_rounded,
          label: DiscPrestaDash.statPending,
          value: '$pendingCount',
          accent: theme.colorScheme.tertiary,
        ),
        PrestataireMetricTile(
          icon: Icons.today_rounded,
          label: DiscPrestaDash.statToday,
          value: '$todayCount',
          accent: theme.colorScheme.primary,
        ),
        PrestataireMetricTile(
          icon: Icons.date_range_rounded,
          label: DiscPrestaDash.statWeek,
          value: '$weekCount',
          accent: theme.colorScheme.secondary,
        ),
      ],
    );
  }
}
