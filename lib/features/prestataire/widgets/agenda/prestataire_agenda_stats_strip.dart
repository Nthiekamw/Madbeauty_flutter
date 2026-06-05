import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../shared/prestataire_metric_tile.dart';

/// Bandeau de synthèse (jour sélectionné, demandes, semaine).
class PrestataireAgendaStatsStrip extends StatelessWidget {
  const PrestataireAgendaStatsStrip({
    super.key,
    required this.selectedDayCount,
    required this.pendingCount,
    required this.weekCount,
  });

  final int selectedDayCount;
  final int pendingCount;
  final int weekCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PrestataireMetricStrip(
      metrics: [
        PrestataireMetricTile(
          icon: Icons.today_rounded,
          label: DiscPrestaAgenda.statSelectedDay,
          value: '$selectedDayCount',
          accent: theme.colorScheme.primary,
        ),
        PrestataireMetricTile(
          icon: Icons.hourglass_top_rounded,
          label: DiscPrestaAgenda.statPending,
          value: '$pendingCount',
          accent: theme.colorScheme.tertiary,
        ),
        PrestataireMetricTile(
          icon: Icons.date_range_rounded,
          label: DiscPrestaAgenda.statWeek,
          value: '$weekCount',
          accent: theme.colorScheme.secondary,
        ),
      ],
    );
  }
}

