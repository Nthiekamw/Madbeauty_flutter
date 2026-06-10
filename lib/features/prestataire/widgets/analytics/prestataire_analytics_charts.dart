import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Graphique en barres des revenus par période.
class PrestataireRevenueBarChart extends StatelessWidget {
  const PrestataireRevenueBarChart({
    super.key,
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

/// Heatmap des jours les plus chargés.
class PrestataireWeekdayHeatmap extends StatelessWidget {
  const PrestataireWeekdayHeatmap({
    super.key,
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
