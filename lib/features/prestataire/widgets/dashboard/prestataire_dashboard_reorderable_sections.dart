import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../logic/prestataire_profile_completeness.dart';
import '../../models/prestataire_dashboard_data.dart';
import '../../models/prestataire_dashboard_layout.dart';
import '../../models/prestataire_dashboard_section_id.dart';
import '../../models/prestataire_reservation_item.dart';
import '../../providers/prestataire_dashboard_layout_provider.dart';
import '../../providers/prestataire_profile_form_provider.dart';
import '../analytics/prestataire_analytics_panel.dart';
import '../profile/prestataire_completeness_badge.dart';
import '../profile/prestataire_profile_enrichment_banner.dart';
import '../profile/prestataire_profile_incomplete_banner.dart';
import '../public/prestataire_salon_hero.dart';
import 'prestataire_dashboard_layout_tile.dart';
import 'prestataire_dashboard_stats_strip.dart';
import 'prestataire_dashboard_subscription_banner.dart';

typedef PrestataireReservationTimelineBuilder = Widget Function(
  List<PrestataireReservationItem> items,
);

/// Corps du dashboard : sections repliables et réordonnables.
class PrestataireDashboardReorderableSections extends ConsumerWidget {
  const PrestataireDashboardReorderableSections({
    super.key,
    required this.profileData,
    required this.title,
    required this.hasHoraires,
    required this.dashboardAsync,
    required this.reservationTimelineBuilder,
  });

  final PrestataireProfileFormData profileData;
  final String title;
  final bool hasHoraires;
  final AsyncValue<PrestataireDashboardData> dashboardAsync;
  final PrestataireReservationTimelineBuilder reservationTimelineBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final layoutAsync = ref.watch(prestataireDashboardLayoutProvider);
    final layout = layoutAsync.asData?.value ?? PrestataireDashboardLayout.defaults;
    final layoutNotifier =
        ref.read(prestataireDashboardLayoutProvider.notifier);

    final dashboard = dashboardAsync.asData?.value;
    final dashboardLoaded = dashboardAsync.hasValue;
    final dashboardLoading = dashboardAsync.isLoading && dashboard == null;
    final dashboardError = dashboardAsync.hasError && dashboard == null;

    final visible = visiblePrestataireDashboardSections(
      layout: layout,
      profileLoaded: true,
      dashboardLoaded: dashboardLoaded && !dashboardError,
      dashboard: dashboard,
    );

    if (visible.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (dashboardLoading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
      itemCount: visible.length,
      onReorder: (oldIndex, newIndex) {
        layoutNotifier.reorderVisible(
          visible,
          oldIndex: oldIndex,
          newIndex: newIndex,
        );
      },
      itemBuilder: (context, index) {
        final sectionId = visible[index];
        final collapsed = layout.isCollapsed(sectionId);

        return PrestataireDashboardLayoutTile(
          key: ValueKey(sectionId),
          sectionId: sectionId,
          index: index,
          collapsed: collapsed,
          onToggleCollapsed: () => layoutNotifier.toggleCollapsed(sectionId),
          wrapInCard: sectionId != PrestataireDashboardSectionId.hero,
          badgeCount: _badgeCount(sectionId, dashboard),
          subtitle: _subtitle(sectionId),
          child: _sectionChild(
            context: context,
            theme: theme,
            sectionId: sectionId,
            dashboard: dashboard,
            dashboardLoading: dashboardLoading,
            dashboardError: dashboardError,
          ),
        );
      },
    );
  }

  int? _badgeCount(
    PrestataireDashboardSectionId id,
    PrestataireDashboardData? dashboard,
  ) {
    if (dashboard == null) return null;
    return switch (id) {
      PrestataireDashboardSectionId.pending => dashboard.pending.length,
      PrestataireDashboardSectionId.today => dashboard.todayConfirmed.length,
      PrestataireDashboardSectionId.week => dashboard.weekConfirmed.length,
      _ => null,
    };
  }

  String? _subtitle(PrestataireDashboardSectionId id) {
    return switch (id) {
      PrestataireDashboardSectionId.pending => DiscPrestaDash.pendingEmpty,
      PrestataireDashboardSectionId.today => DiscPrestaDash.todayEmpty,
      PrestataireDashboardSectionId.week => DiscPrestaDash.weekEmpty,
      _ => null,
    };
  }

  Widget _sectionChild({
    required BuildContext context,
    required ThemeData theme,
    required PrestataireDashboardSectionId sectionId,
    required PrestataireDashboardData? dashboard,
    required bool dashboardLoading,
    required bool dashboardError,
  }) {
    switch (sectionId) {
      case PrestataireDashboardSectionId.hero:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrestataireSalonHero(
              title: title,
              subtitle: profileData.isProfessionallyComplete
                  ? DiscPrestaDash.welcome
                  : DiscPrestaDash.profileMissing,
              avatarUrl: profileData.avatarUrl,
              trailing: PrestataireCompletenessBadge(
                complete: profileData.isProfessionallyComplete,
              ),
            ),
            if (!profileData.isProfessionallyComplete)
              const PrestataireProfileIncompleteBanner(),
            if (profileData.isProfessionallyComplete &&
                !profileData.isProfileFullyEnriched(hasHoraires: hasHoraires))
              const PrestataireProfileEnrichmentBanner(),
            if (profileData.isProfessionallyComplete)
              const PrestataireDashboardSubscriptionBanner(),
          ],
        );
      case PrestataireDashboardSectionId.analytics:
        return const PrestataireAnalyticsPanel(hideOuterHeader: true);
      case PrestataireDashboardSectionId.stats:
        if (dashboardLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (dashboardError || dashboard == null) {
          return DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: DiscPrestaDash.loadErr,
            body: DiscList.pullDownHint,
            iconColor: theme.colorScheme.error,
          );
        }
        return PrestataireDashboardStatsStrip(
          pendingCount: dashboard.pending.length,
          todayCount: dashboard.todayConfirmed.length,
          weekCount: dashboard.weekConfirmed.length,
        );
      case PrestataireDashboardSectionId.pending:
      case PrestataireDashboardSectionId.today:
      case PrestataireDashboardSectionId.week:
        if (dashboardLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (dashboardError || dashboard == null) {
          return const SizedBox.shrink();
        }
        final items = switch (sectionId) {
          PrestataireDashboardSectionId.pending => dashboard.pending,
          PrestataireDashboardSectionId.today => dashboard.todayConfirmed,
          PrestataireDashboardSectionId.week => dashboard.weekConfirmed,
          _ => <PrestataireReservationItem>[],
        };
        if (items.isEmpty) {
          return DiscoveryEmptyState(
            icon: _emptyIcon(sectionId),
            title: _emptyTitle(sectionId),
            body: _subtitle(sectionId) ?? '',
            iconColor: (sectionId == PrestataireDashboardSectionId.pending
                    ? theme.colorScheme.tertiary
                    : theme.colorScheme.primary)
                .withValues(alpha: 0.85),
          );
        }
        return reservationTimelineBuilder(items);
    }
  }

  IconData _emptyIcon(PrestataireDashboardSectionId id) {
    return switch (id) {
      PrestataireDashboardSectionId.pending => Icons.inbox_rounded,
      PrestataireDashboardSectionId.today => Icons.today_rounded,
      PrestataireDashboardSectionId.week => Icons.date_range_rounded,
      _ => Icons.event_busy_outlined,
    };
  }

  String _emptyTitle(PrestataireDashboardSectionId id) {
    return switch (id) {
      PrestataireDashboardSectionId.pending => DiscPrestaDash.pendingEmptyTitle,
      PrestataireDashboardSectionId.today => DiscPrestaDash.todayEmptyTitle,
      PrestataireDashboardSectionId.week => DiscPrestaDash.weekEmptyTitle,
      _ => '',
    };
  }
}
