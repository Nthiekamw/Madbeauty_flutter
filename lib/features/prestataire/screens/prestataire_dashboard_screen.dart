import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router/navigation_extensions.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/disponibilite_provider.dart';
import '../providers/prestataire_analytics_provider.dart';
import '../providers/prestataire_dashboard_layout_provider.dart';
import '../providers/prestataire_dashboard_provider.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/agenda/prestataire_agenda_reservation_card.dart';
import '../providers/prestataire_dashboard_overview_provider.dart';
import '../widgets/dashboard/prestataire_dashboard_overview_grid.dart';
import '../widgets/dashboard/prestataire_dashboard_reorderable_sections.dart';
import '../widgets/profile/overview/prestataire_profile_load_error.dart';
import '../widgets/workspace/prestataire_profile_completion_card.dart';
import '../widgets/workspace/prestataire_workspace_shell.dart';

class PrestataireDashboardScreen extends ConsumerStatefulWidget {
  const PrestataireDashboardScreen({super.key});

  @override
  ConsumerState<PrestataireDashboardScreen> createState() =>
      _PrestataireDashboardScreenState();
}

class _PrestataireDashboardScreenState
    extends ConsumerState<PrestataireDashboardScreen> {
  String? _actingReservationId;

  Future<void> _refresh() async {
    ref.invalidate(prestataireProfileFormProvider);
    ref.invalidate(prestataireAnalyticsProvider);
    ref.invalidate(prestataireDashboardOverviewProvider);
    ref.invalidate(prestataireDashboardProvider);
    ref.invalidate(prestataireDashboardLayoutProvider);
    await Future.wait([
      ref.read(prestataireProfileFormProvider.future),
      ref.read(prestataireAnalyticsProvider.future),
      ref.read(prestataireDashboardProvider.future),
      ref.read(prestataireDashboardLayoutProvider.future),
    ]);
  }

  PrestataireReservationActions get _actions =>
      PrestataireReservationActions(ref, context);

  Future<void> _runAction(
    String id,
    Future<bool> Function() action,
  ) async {
    setState(() => _actingReservationId = id);
    await action();
    if (mounted) setState(() => _actingReservationId = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(prestataireProfileFormProvider);
    final horairesAsync = ref.watch(prestataireHorairesProvider);
    final dashboardAsync = ref.watch(prestataireDashboardProvider);
    final hasHoraires = horairesAsync.maybeWhen(
      data: (h) => h.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: profileAsync.when(
          data: (data) {
            final showProfileCard = !data.isProfileFullyEnriched(
              hasHoraires: hasHoraires,
            );

            return PrestataireWorkspaceShell(
              onRefresh: _refresh,
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (showProfileCard)
                      const SliverToBoxAdapter(
                        child: PrestataireProfileCompletionCard(),
                      ),
                    const SliverToBoxAdapter(
                      child: PrestataireDashboardOverviewGrid(),
                    ),
                    PrestataireDashboardReorderableSections(
                      embedInParentScroll: true,
                      profileData: data,
                      hasHoraires: hasHoraires,
                      dashboardAsync: dashboardAsync,
                      reservationTimelineBuilder: (items) =>
                          _ReservationTimeline(
                        items: items,
                        actingId: _actingReservationId,
                        onAccept: (id) =>
                            _runAction(id, () => _actions.accept(id)),
                        onReject: (id) =>
                            _runAction(id, () => _actions.reject(id)),
                        onMarkDone: (id) =>
                            _runAction(id, () => _actions.markDone(id)),
                        onItemTap: (id) =>
                            context.pushPrestataireReservationDetail(id),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (_, __) => PrestataireProfileLoadError(
            onRetry: () => ref.invalidate(prestataireProfileFormProvider),
          ),
          loading: () => const PrestataireWorkspaceShell(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

class _ReservationTimeline extends StatelessWidget {
  const _ReservationTimeline({
    required this.items,
    required this.actingId,
    required this.onAccept,
    required this.onReject,
    required this.onMarkDone,
    required this.onItemTap,
  });

  final List<PrestataireReservationItem> items;
  final String? actingId;
  final void Function(String id) onAccept;
  final void Function(String id) onReject;
  final void Function(String id) onMarkDone;
  final void Function(String id) onItemTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = items[index];
        final busy = actingId == item.id;
        return PrestataireAgendaReservationCard(
          item: item,
          busy: busy,
          showTimelineConnector: index < items.length - 1,
          onTap: () => onItemTap(item.id),
          onAccept: busy ? null : () => onAccept(item.id),
          onReject: busy ? null : () => onReject(item.id),
          onMarkDone: busy ? null : () => onMarkDone(item.id),
        );
      },
    );
  }
}
