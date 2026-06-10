import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../models/prestataire_analytics_data.dart';
import '../../models/prestataire_analytics_period.dart';
import '../shared/prestataire_metric_tile.dart';

/// Section réservations et taux de conversion.
class PrestataireAnalyticsReservationsSection extends StatelessWidget {
  const PrestataireAnalyticsReservationsSection({
    super.key,
    required this.data,
    required this.period,
  });

  final PrestataireAnalyticsData data;
  final PrestataireAnalyticsPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${DiscPrestaAnalytics.reservationsTitle} (${period.label})',
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrestataireMetricTile(
                  icon: Icons.inbox_rounded,
                  label: DiscPrestaAnalytics.totalRequests,
                  value: '${data.periodTotalRequests}',
                  accent: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrestataireMetricTile(
                  icon: Icons.cancel_outlined,
                  label: DiscPrestaAnalytics.cancelled,
                  value: '${data.periodCancelled}',
                  accent: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: PrestataireMetricTile(
                  icon: Icons.check_circle_outline_rounded,
                  label: DiscPrestaAnalytics.confirmed,
                  value: '${data.periodConfirmed}',
                  accent: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrestataireMetricTile(
                  icon: Icons.done_all_rounded,
                  label: DiscPrestaAnalytics.completed,
                  value: '${data.periodCompleted}',
                  accent: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.percent_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DiscPrestaAnalytics.conversion,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DiscPrestaAnalytics.conversionHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DiscPrestaAnalytics.percentValue(data.conversionPercent),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
