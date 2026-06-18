import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/widgets/discovery/content/discovery_section_header.dart';
import '../../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../providers/dashboard/prestataire_dashboard_overview_provider.dart';
import '../layout/prestataire_dashboard_insets.dart';
import '../layout/prestataire_dashboard_layout_sheet.dart';

/// Grille « Aperçu » 2×2 (style maquette).
class PrestataireDashboardOverviewGrid extends ConsumerWidget {
  const PrestataireDashboardOverviewGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(prestataireDashboardOverviewProvider);

    return Padding(
      padding: PrestataireDashboardInsets.page(context).copyWith(
        top: 12,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DiscoverySectionHeader(
            title: DiscPrestaDash.overviewTitle,
            icon: Icons.insights_rounded,
            compact: true,
            actionLabel: DiscPrestaDash.layoutOrganizeAction,
            onAction: () => showPrestataireDashboardLayoutSheet(context, ref),
          ),
          const SizedBox(height: 12),
          overviewAsync.when(
            loading: () => _OverviewGridSkeleton(),
            error: (_, __) => DiscoverySectionError(
              message: DiscPrestaDash.loadErr,
              onRetry: () => ref.invalidate(
                prestataireDashboardOverviewProvider,
              ),
            ),
            data: (data) => _OverviewGridBody(data: data),
          ),
        ],
      ),
    );
  }
}

class _OverviewGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final track = DiscoveryShimmer.colors(theme).track;
    final radius = BorderRadius.circular(14);

    return DiscoveryShimmer.wrap(
      context: context,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: track,
              borderRadius: radius,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewGridBody extends StatelessWidget {
  const _OverviewGridBody({required this.data});

  final PrestataireDashboardOverviewData data;

  static const double _spacing = 10;

  @override
  Widget build(BuildContext context) {
    final cards = <_OverviewCard>[
      _OverviewCard(
        icon: Icons.calendar_today_rounded,
        value: '${data.todayAppointments}',
        label: DiscPrestaDash.overviewToday,
        trend: formatOverviewTrend(
          percent: null,
          delta: data.todayVsYesterdayDelta,
          vsLabel: DiscPrestaDash.overviewVsYesterday,
        ),
        positiveTrend: (data.todayVsYesterdayDelta ?? 0) >= 0,
      ),
      _OverviewCard(
        icon: Icons.people_outline_rounded,
        value: '${data.clientsThisMonth}',
        label: DiscPrestaDash.overviewClientsMonth,
        trend: formatOverviewTrend(
          percent: data.clientsChangePercent,
          vsLabel: DiscPrestaDash.overviewVsLastMonth,
        ),
        positiveTrend: (data.clientsChangePercent ?? 0) >= 0,
      ),
      _OverviewCard(
        icon: Icons.account_balance_wallet_outlined,
        value: formatOverviewCurrency(data.monthRevenueEur),
        label: DiscPrestaDash.overviewRevenueMonth,
        trend: formatOverviewTrend(
          percent: data.monthRevenueChangePercent,
          vsLabel: DiscPrestaDash.overviewVsLastMonth,
        ),
        positiveTrend: (data.monthRevenueChangePercent ?? 0) >= 0,
      ),
      _OverviewCard(
        icon: Icons.trending_up_rounded,
        value: formatOverviewCurrency(data.totalRevenueEur),
        label: DiscPrestaDash.overviewRevenueTotal,
        trend: formatOverviewTrend(
          percent: data.totalRevenueChangePercent,
          vsLabel: DiscPrestaDash.overviewVsLastMonth,
        ),
        positiveTrend: (data.totalRevenueChangePercent ?? 0) >= 0,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            for (var row = 0; row < 2; row++) ...[
              if (row > 0) const SizedBox(height: _spacing),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var col = 0; col < 2; col++) ...[
                      if (col > 0) const SizedBox(width: _spacing),
                      Expanded(child: cards[row * 2 + col]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.trend,
    required this.positiveTrend,
  });

  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final bool positiveTrend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceFor(theme.brightness),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.28 : 0.1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -0.5,
                      fontSize: 22,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              softWrap: true,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
            if (trend.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        positiveTrend
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 13,
                        color: positiveTrend
                            ? AppColors.success
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          trend,
                          softWrap: true,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                            height: 1.2,
                            color: theme.colorScheme.onSurface,
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
    );
  }
}
