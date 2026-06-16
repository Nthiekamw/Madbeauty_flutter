import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../logic/admin_country_format.dart';
import '../models/admin_country_reservation_stats.dart';
import '../providers/admin_country_stats_provider.dart';

class AdminCountryStatsSection extends ConsumerWidget {
  const AdminCountryStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(adminCountryStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DiscProfile.adminCountryStatsTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        statsAsync.when(
          data: (stats) {
            if (stats.isEmpty) {
              return _EmptyCard(theme: theme);
            }
            return _CountryStatsList(stats: stats);
          },
          loading: () => const SizedBox(
            height: 120,
            child: DiscoveryListSkeleton(
              rowCount: 2,
              rowHeight: 52,
              padding: EdgeInsets.zero,
            ),
          ),
          error: (_, __) => _EmptyCard(theme: theme),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DiscoveryStyles.cardBorderRadius,
        color: theme.colorScheme.surface,
        border: Border.all(color: AppColors.adminBorder30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.public_outlined,
              color: AppColors.adminAccentMid,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DiscProfile.adminCountryStatsEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryStatsList extends StatelessWidget {
  const _CountryStatsList({required this.stats});

  final List<AdminCountryReservationStats> stats;

  @override
  Widget build(BuildContext context) {
    final r = DiscoveryResponsive.of(context);
    final maxReservations = stats
        .map((s) => s.reservationsTotal)
        .fold<int>(0, (a, b) => a > b ? a : b);

    if (r.isWide) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: stats
            .map(
              (entry) => SizedBox(
                width: (r.contentMaxWidth - 10) / 2,
                child: _CountryStatCard(
                  entry: entry,
                  maxReservations: maxReservations,
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _CountryStatCard(
            entry: stats[i],
            maxReservations: maxReservations,
          ),
        ],
      ],
    );
  }
}

class _CountryStatCard extends StatelessWidget {
  const _CountryStatCard({
    required this.entry,
    required this.maxReservations,
  });

  final AdminCountryReservationStats entry;
  final int maxReservations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = adminCountryLabel(entry.countryCode);
    final flag = adminCountryFlag(entry.countryCode);
    final barFraction = maxReservations == 0
        ? 0.0
        : entry.reservationsTotal / maxReservations;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DiscoveryStyles.cardBorderRadius,
        color: theme.colorScheme.surface,
        border: Border.all(color: AppColors.adminBorder30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (entry.countryCode != 'XX')
                        Text(
                          entry.countryCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${entry.reservationsTotal}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w900,
                    color: AppColors.adminAccentMid,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: barFraction,
                minHeight: 6,
                backgroundColor: AppColors.adminBg12,
                color: AppColors.adminAccentMid,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MetricChip(
                  icon: Icons.calendar_today_outlined,
                  label: DiscProfile.adminCountryStatsThisMonth,
                  value: '${entry.reservationsThisMonth}',
                ),
                _MetricChip(
                  icon: Icons.storefront_outlined,
                  label: DiscProfile.adminCountryStatsSalons,
                  value: '${entry.prestatairesCount}',
                ),
                if (entry.revenueCapturedCents > 0)
                  _MetricChip(
                    icon: Icons.euro_rounded,
                    label: DiscProfile.adminCountryStatsRevenue,
                    value: CurrencyFormat.eurCents(entry.revenueCapturedCents),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.adminBg12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.adminBorder30.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.adminAccentMid),
          const SizedBox(width: 4),
          Text(
            '$label · $value',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
