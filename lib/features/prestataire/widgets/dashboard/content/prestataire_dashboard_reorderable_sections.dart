import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../logic/prestataire_profile_completeness.dart';
import '../../../models/prestataire_dashboard_data.dart';
import '../../../models/prestataire_dashboard_layout.dart';
import '../../../models/prestataire_dashboard_section_id.dart';
import '../../../models/prestataire_reservation_item.dart';
import '../../../providers/boutique/boutique_providers.dart';
import '../../../providers/dashboard/prestataire_dashboard_layout_provider.dart';
import '../../../providers/profile/prestataire_profile_form_provider.dart';
import '../../analytics/prestataire_analytics_panel.dart';
import '../layout/prestataire_dashboard_layout_tile.dart';
import '../layout/prestataire_dashboard_section_empty.dart';
import 'prestataire_dashboard_boutique_card.dart';

typedef PrestataireReservationTimelineBuilder = Widget Function(
  List<PrestataireReservationItem> items,
);

/// Corps du dashboard : sections repliables.
class PrestataireDashboardReorderableSections extends ConsumerWidget {
  const PrestataireDashboardReorderableSections({
    super.key,
    required this.profileData,
    required this.hasHoraires,
    required this.dashboardAsync,
    required this.reservationTimelineBuilder,
    this.embedInParentScroll = false,
  });

  final PrestataireProfileFormData profileData;
  final bool hasHoraires;
  final AsyncValue<PrestataireDashboardData> dashboardAsync;
  final PrestataireReservationTimelineBuilder reservationTimelineBuilder;
  final bool embedInParentScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiles = _buildSectionTiles(context, ref);
    final footer = _footerTiles(context, ref);

    if (embedInParentScroll) {
      return SliverMainAxisGroup(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([...tiles, ...footer]),
            ),
          ),
        ],
      );
    }

    return ListView(
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      children: [...tiles, ...footer],
    );
  }

  List<Widget> _buildSectionTiles(BuildContext context, WidgetRef ref) {
    final visible = _visibleSections(ref);
    if (visible.isEmpty && !_profileComplete) {
      final dashboard = dashboardAsync.asData?.value;
      final dashboardLoading =
          dashboardAsync.isLoading && dashboard == null;
      if (dashboardLoading) {
        return const [
          Padding(
            padding: EdgeInsets.all(48),
            child: DiscoveryListSkeleton(rowCount: 2, rowHeight: 100),
          ),
        ];
      }
      return const [];
    }

    return [
      for (final sectionId in visible)
        _buildSectionTile(
          context: context,
          ref: ref,
          sectionId: sectionId,
        ),
    ];
  }

  List<PrestataireDashboardSectionId> _visibleSections(WidgetRef ref) {
    final layoutAsync = ref.watch(prestataireDashboardLayoutProvider);
    final layout =
        layoutAsync.asData?.value ?? PrestataireDashboardLayout.defaults;
    final dashboard = dashboardAsync.asData?.value;
    final dashboardLoaded = dashboardAsync.hasValue;
    final dashboardError = dashboardAsync.hasError && dashboard == null;

    return visiblePrestataireDashboardSections(
      layout: layout,
      profileLoaded: true,
      dashboardLoaded: dashboardLoaded && !dashboardError,
      dashboard: dashboard,
    );
  }

  bool get _profileComplete => profileData.isProfileFullyEnriched(
        hasHoraires: hasHoraires,
      );

  Widget _buildSectionTile({
    required BuildContext context,
    required WidgetRef ref,
    required PrestataireDashboardSectionId sectionId,
  }) {
    final theme = Theme.of(context);
    final layoutAsync = ref.watch(prestataireDashboardLayoutProvider);
    final layout =
        layoutAsync.asData?.value ?? PrestataireDashboardLayout.defaults;
    final layoutNotifier =
        ref.read(prestataireDashboardLayoutProvider.notifier);
    final dashboard = dashboardAsync.asData?.value;
    final dashboardLoading = dashboardAsync.isLoading && dashboard == null;
    final dashboardError = dashboardAsync.hasError && dashboard == null;

    final boutiqueOpen =
        ref.watch(ownBoutiqueOrdersOpenCountProvider).asData?.value ?? 0;

    return PrestataireDashboardLayoutTile(
      key: ValueKey(sectionId),
      sectionId: sectionId,
      collapsed: _isSectionCollapsed(
        sectionId: sectionId,
        layout: layout,
        dashboard: dashboard,
        boutiqueOpen: boutiqueOpen,
      ),
      onToggleCollapsed: () => layoutNotifier.toggleCollapsed(sectionId),
      badgeCount: _badgeCount(sectionId, dashboard, boutiqueOpen),
      child: _sectionChild(
        context: context,
        theme: theme,
        sectionId: sectionId,
        dashboard: dashboard,
        dashboardLoading: dashboardLoading,
        dashboardError: dashboardError,
      ),
    );
  }

  List<Widget> _footerTiles(BuildContext context, WidgetRef ref) {
    return const [SizedBox(height: 24)];
  }

  int? _badgeCount(
    PrestataireDashboardSectionId id,
    PrestataireDashboardData? dashboard,
    int boutiqueOpen,
  ) {
    return switch (id) {
      PrestataireDashboardSectionId.pending => dashboard?.pending.length,
      PrestataireDashboardSectionId.today => dashboard?.todayConfirmed.length,
      PrestataireDashboardSectionId.week => dashboard?.weekConfirmed.length,
      PrestataireDashboardSectionId.boutique =>
        boutiqueOpen > 0 ? boutiqueOpen : null,
      _ => null,
    };
  }

  bool _isSectionCollapsed({
    required PrestataireDashboardSectionId sectionId,
    required PrestataireDashboardLayout layout,
    required PrestataireDashboardData? dashboard,
    required int boutiqueOpen,
  }) {
    if (sectionId == PrestataireDashboardSectionId.boutique &&
        boutiqueOpen > 0) {
      return false;
    }
    if (dashboard != null) {
      final hasItems = switch (sectionId) {
        PrestataireDashboardSectionId.pending => dashboard.pending.isNotEmpty,
        PrestataireDashboardSectionId.today =>
          dashboard.todayConfirmed.isNotEmpty,
        _ => false,
      };
      if (hasItems) return false;
    }
    return layout.isCollapsed(sectionId);
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
      case PrestataireDashboardSectionId.stats:
        return const SizedBox.shrink();
      case PrestataireDashboardSectionId.boutique:
        return const PrestataireDashboardBoutiqueCard(
          hideOuterHeader: true,
          embedInSection: true,
        );
      case PrestataireDashboardSectionId.analytics:
        return const PrestataireAnalyticsPanel(
          hideOuterHeader: true,
          dashboardCompact: true,
        );
      case PrestataireDashboardSectionId.pending:
      case PrestataireDashboardSectionId.today:
      case PrestataireDashboardSectionId.week:
        if (dashboardLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: DiscoveryListSkeleton(rowCount: 2, rowHeight: 100),
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
        final items = switch (sectionId) {
          PrestataireDashboardSectionId.pending => dashboard.pending,
          PrestataireDashboardSectionId.today => dashboard.todayConfirmed,
          PrestataireDashboardSectionId.week => dashboard.weekConfirmed,
          _ => <PrestataireReservationItem>[],
        };
        if (items.isEmpty) {
          return PrestataireDashboardSectionEmpty(
            icon: switch (sectionId) {
              PrestataireDashboardSectionId.pending => Icons.inbox_outlined,
              PrestataireDashboardSectionId.today =>
                Icons.event_available_outlined,
              _ => Icons.date_range_outlined,
            },
            message: switch (sectionId) {
              PrestataireDashboardSectionId.pending =>
                DiscPrestaDash.pendingEmpty,
              PrestataireDashboardSectionId.today => DiscPrestaDash.todayEmpty,
              _ => DiscPrestaDash.weekEmpty,
            },
          );
        }
        return reservationTimelineBuilder(items);
    }
  }
}
