import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../providers/analytics/prestataire_analytics_period_provider.dart';
import '../../providers/analytics/prestataire_analytics_provider.dart';
import '../shared/prestataire_section_header.dart';
import 'prestataire_analytics_dashboard_compact.dart';
import 'prestataire_analytics_format.dart';
import 'prestataire_analytics_occupancy_section.dart';
import 'prestataire_analytics_period_filter.dart';
import 'prestataire_analytics_reservations_section.dart';
import 'prestataire_analytics_revenue_section.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(prestataireAnalyticsPeriodProvider);
    final analyticsAsync = ref.watch(prestataireAnalyticsProvider);

    if (dashboardCompact) {
      return analyticsAsync.when(
        loading: () => const DiscoveryListSkeleton(
          rowCount: 2,
          rowHeight: 72,
          padding: EdgeInsets.symmetric(vertical: 8),
        ),
        error: (_, __) => DiscoverySectionError(
          message: DiscPrestaAnalytics.loadErr,
          onRetry: () => ref.invalidate(prestataireAnalyticsProvider),
        ),
        data: (data) => PrestataireAnalyticsDashboardCompact(
          data: data,
          period: period,
          currency: prestataireAnalyticsCurrency,
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
          child: PrestataireAnalyticsPeriodFilter(
            selected: period,
            onSelected: (p) => ref
                .read(prestataireAnalyticsPeriodProvider.notifier)
                .setPeriod(p),
          ),
        ),
        const SizedBox(height: 12),
        analyticsAsync.when(
          loading: () => const DiscoveryListSkeleton(
            rowCount: 3,
            rowHeight: 88,
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          error: (_, __) => DiscoverySectionError(
            message: DiscPrestaAnalytics.loadErr,
            onRetry: () => ref.invalidate(prestataireAnalyticsProvider),
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrestataireAnalyticsRevenueSection(
                data: data,
                currency: prestataireAnalyticsCurrency,
                period: period,
              ),
              const SizedBox(height: 12),
              PrestataireAnalyticsOccupancySection(
                data: data,
                period: period,
              ),
              const SizedBox(height: 12),
              PrestataireAnalyticsReservationsSection(
                data: data,
                period: period,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
