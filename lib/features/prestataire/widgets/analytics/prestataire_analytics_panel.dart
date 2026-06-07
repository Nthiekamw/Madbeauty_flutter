import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../logic/prestataire_analytics_calculator.dart';
import '../../models/prestataire_analytics_data.dart';
import '../../models/prestataire_analytics_period.dart';
import '../../providers/prestataire_analytics_period_provider.dart';
import '../../providers/prestataire_analytics_provider.dart';
import '../shared/prestataire_metric_tile.dart';
import '../shared/prestataire_section_header.dart';
import '../../../../shared/theme/app_colors.dart';

/// Bloc analytique : filtre période, revenus, occupation, réservations.
class PrestataireAnalyticsPanel extends ConsumerWidget {
  const PrestataireAnalyticsPanel({
    super.key,
    this.hideOuterHeader = false,
    this.dashboardCompact = false,
  });

  /// Masque le titre du bloc (déjà affiché par la tuile dashboard repliable).
  final bool hideOuterHeader;

  /// Vue épurée intégrée au dashboard.
  final bool dashboardCompact;

  static final _currency = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(prestataireAnalyticsPeriodProvider);
    final analyticsAsync = ref.watch(prestataireAnalyticsProvider);

    if (dashboardCompact) {
      return analyticsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Text(
          DiscPrestaAnalytics.loadErr,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        data: (data) => _DashboardCompactAnalytics(
          data: data,
          period: period,
          currency: _currency,
          onPeriodSelected: (p) => ref
              .read(prestataireAnalyticsPeriodProvider.notifier)
              .setPeriod(p),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hideOuterHeader) ...[
          PrestataireSectionHeader(
            icon: Icons.insights_rounded,
            title: DiscPrestaAnalytics.sectionTitle,
            subtitle: DiscPrestaAnalytics.revenueBreakdown,
            iconColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
        ],
        DiscoverySurfaceCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: _PeriodFilter(
            selected: period,
            onSelected: (p) => ref
                .read(prestataireAnalyticsPeriodProvider.notifier)
                .setPeriod(p),
          ),
        ),
        const SizedBox(height: 12),
        analyticsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => DiscoverySurfaceCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                DiscPrestaAnalytics.loadErr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RevenueSection(
                data: data,
                currency: _currency,
                period: period,
              ),
              const SizedBox(height: 12),
              _OccupancySection(data: data, period: period),
              const SizedBox(height: 12),
              _ReservationsSection(data: data, period: period),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardCompactAnalytics extends StatelessWidget {
  const _DashboardCompactAnalytics({
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
            child: _RevenueBarChart(
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

class _PeriodFilter extends StatelessWidget {
  const _PeriodFilter({
    required this.selected,
    required this.onSelected,
  });

  final PrestataireAnalyticsPeriod selected;
  final ValueChanged<PrestataireAnalyticsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PrestataireAnalyticsPeriod>(
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
      segments: [
        for (final p in PrestataireAnalyticsPeriod.values)
          ButtonSegment(
            value: p,
            label: Text(
              p.label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onSelected(set.first),
    );
  }
}

class _RevenueSection extends StatelessWidget {
  const _RevenueSection({
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
              child: _RevenueBarChart(
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

class _OccupancySection extends StatelessWidget {
  const _OccupancySection({
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
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
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
          _WeekdayHeatmap(
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

class _WeekdayHeatmap extends StatelessWidget {
  const _WeekdayHeatmap({
    required this.intensities,
    required this.labels,
    required this.accent,
    required this.busiestWeekday,
  });

  final List<double> intensities;
  final List<String> labels;
  final Color accent;
  final int? busiestWeekday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasData = intensities.any((v) => v > 0);

    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 0.85,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: hasData
                          ? LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                accent.withValues(
                                  alpha: 0.15 + intensities[i] * 0.75,
                                ),
                                accent.withValues(
                                  alpha: 0.05 + intensities[i] * 0.25,
                                ),
                              ],
                            )
                          : null,
                      color: hasData
                          ? null
                          : theme.colorScheme.surfaceContainerHighest,
                      border: Border.all(
                        color: busiestWeekday == i + 1
                            ? accent
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: busiestWeekday == i + 1 ? 2.5 : 1,
                      ),
                      boxShadow: busiestWeekday == i + 1
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: busiestWeekday == i + 1
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: accent,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: busiestWeekday == i + 1
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: busiestWeekday == i + 1
                        ? accent
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RevenueBarChart extends StatelessWidget {
  const _RevenueBarChart({
    required this.amounts,
    required this.labels,
    required this.accent,
  });

  final List<double> amounts;
  final List<String> labels;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = amounts.isEmpty
        ? 1.0
        : amounts.reduce((a, b) => a > b ? a : b) * 1.15;
    final safeMax = maxY <= 0 ? 1.0 : maxY;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: safeMax,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: safeMax / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${value.round()}',
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < amounts.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: amounts[i],
                  color: accent,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 350),
    );
  }
}

class _ReservationsSection extends StatelessWidget {
  const _ReservationsSection({
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

