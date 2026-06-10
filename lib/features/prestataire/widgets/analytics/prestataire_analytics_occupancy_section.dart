import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../logic/prestataire_analytics_calculator.dart';
import '../../models/prestataire_analytics_data.dart';
import '../../models/prestataire_analytics_period.dart';
import 'prestataire_analytics_charts.dart';

/// Section occupation / heatmap hebdomadaire.
class PrestataireAnalyticsOccupancySection extends StatelessWidget {
  const PrestataireAnalyticsOccupancySection({
    super.key,
    required this.data,
    required this.period,
  });

  final PrestataireAnalyticsData data;
  final PrestataireAnalyticsPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final busiestName = data.busiestWeekday != null
        ? PrestataireAnalyticsCalculator.weekdayName(data.busiestWeekday!)
        : null;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscPrestaAnalytics.occupancyTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${DiscPrestaAnalytics.occupancyHint} (${period.label})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${data.occupancyPercent.toStringAsFixed(0)} %',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (data.occupancyPercent / 100).clamp(0, 1),
                    minHeight: 10,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            DiscPrestaAnalytics.occupancyHeatmap,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DiscPrestaAnalytics.busiestDay(busiestName),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          PrestataireWeekdayHeatmap(
            intensities: data.weekdayHeatmap,
            labels: data.weekdayLabels,
            accent: primary,
            busiestWeekday: data.busiestWeekday,
          ),
        ],
      ),
    );
  }
}
