import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../logic/prestataire_analytics_calculator.dart';
import '../../models/prestataire_analytics_data.dart';
import '../../models/prestataire_analytics_period.dart';
import 'prestataire_analytics_charts.dart';

/// Vue analytique compacte intégrée au dashboard prestataire.
class PrestataireAnalyticsDashboardCompact extends StatelessWidget {
  const PrestataireAnalyticsDashboardCompact({
    super.key,
    required this.data,
    required this.period,
    required this.currency,
    required this.onPeriodSelected,
  });

  final PrestataireAnalyticsData data;
  final PrestataireAnalyticsPeriod period;
  final NumberFormat currency;
  final ValueChanged<PrestataireAnalyticsPeriod> onPeriodSelected;

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
    final busiestName = data.busiestWeekday != null
        ? PrestataireAnalyticsCalculator.weekdayName(data.busiestWeekday!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaAnalytics.dashboardPeriodLabel,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<PrestataireAnalyticsPeriod>(
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
          segments: [
            for (final p in PrestataireAnalyticsPeriod.values)
              ButtonSegment(
                value: p,
                label: Text(p.label),
              ),
          ],
          selected: {period},
          onSelectionChanged: (set) => onPeriodSelected(set.first),
        ),
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withValues(alpha: 0.12),
                theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.4 : 0.7,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscPrestaAnalytics.dashboardRevenueHeadline,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  currency.format(data.periodRevenueEur),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w900,
                    color: primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DiscPrestaAnalytics.dashboardRevenueHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (evolution != null) ...[
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: evolutionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            evolution >= 0
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 18,
                            color: evolutionColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${DiscPrestaAnalytics.dashboardRevenueTrend} : ${DiscPrestaAnalytics.evolutionPercent(evolution)}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: evolutionColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DashboardInsightTile(
                icon: Icons.calendar_month_outlined,
                title: DiscPrestaAnalytics.dashboardAgendaTitle,
                value: '${data.occupancyPercent.toStringAsFixed(0)} %',
                hint: DiscPrestaAnalytics.dashboardAgendaHint,
                accent: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DashboardInsightTile(
                icon: Icons.check_circle_outline_rounded,
                title: DiscPrestaAnalytics.dashboardAcceptanceTitle,
                value: DiscPrestaAnalytics.percentValue(data.conversionPercent),
                hint: DiscPrestaAnalytics.dashboardAcceptanceHint,
                accent: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _DashboardReservationsSummary(data: data),
        if (data.chartRevenueEur.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            DiscPrestaAnalytics.dashboardChartTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: PrestataireRevenueBarChart(
              amounts: data.chartRevenueEur,
              labels: data.chartLabels,
              accent: primary,
            ),
          ),
        ],
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_outlined,
                  size: 20,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DiscPrestaAnalytics.dashboardBusiestTitle,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DiscPrestaAnalytics.busiestDay(busiestName),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardInsightTile extends StatelessWidget {
  const _DashboardInsightTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.hint,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String value;
  final String hint;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w900,
                color: accent,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hint,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardReservationsSummary extends StatelessWidget {
  const _DashboardReservationsSummary({required this.data});

  final PrestataireAnalyticsData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DiscPrestaAnalytics.dashboardReservationsTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    label: DiscPrestaAnalytics.totalRequests,
                    value: '${data.periodTotalRequests}',
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryChip(
                    label: DiscPrestaAnalytics.confirmed,
                    value: '${data.periodConfirmed}',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryChip(
                    label: DiscPrestaAnalytics.completed,
                    value: '${data.periodCompleted}',
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
