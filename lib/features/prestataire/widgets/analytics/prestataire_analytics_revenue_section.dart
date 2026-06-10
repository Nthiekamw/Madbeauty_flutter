import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../models/prestataire_analytics_data.dart';
import '../../models/prestataire_analytics_period.dart';
import 'prestataire_analytics_charts.dart';

/// Section revenus du panneau analytique complet.
class PrestataireAnalyticsRevenueSection extends StatelessWidget {
  const PrestataireAnalyticsRevenueSection({
    super.key,
    required this.data,
    required this.currency,
    required this.period,
  });

  final PrestataireAnalyticsData data;
  final NumberFormat currency;
  final PrestataireAnalyticsPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final evolution = data.revenueChangePercent;
    final evolutionColor = evolution == null
        ? theme.colorScheme.onSurfaceVariant
        : evolution >= 0
            ? AppColors.success
            : theme.colorScheme.error;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscPrestaAnalytics.revenueTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DiscPrestaAnalytics.revenuePeriod} (${period.label})',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency.format(data.periodRevenueEur),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DiscPrestaAnalytics.revenueVsPrev,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        evolution != null && evolution >= 0
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 18,
                        color: evolutionColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DiscPrestaAnalytics.evolutionPercent(evolution),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: evolutionColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (data.chartRevenueEur.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              DiscPrestaAnalytics.revenueChart,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: PrestataireRevenueBarChart(
                amounts: data.chartRevenueEur,
                labels: data.chartLabels,
                accent: primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
