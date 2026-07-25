import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router/navigation_extensions.dart';
import '../../../core/constants/app_strings.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/agenda/disponibilite_provider.dart';
import '../providers/analytics/prestataire_analytics_provider.dart';
import '../providers/dashboard/prestataire_dashboard_layout_provider.dart';
import '../providers/dashboard/prestataire_dashboard_provider.dart';
import '../providers/profile/prestataire_profile_form_provider.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import '../widgets/agenda/prestataire_agenda_reservation_card.dart';
import '../widgets/dashboard/requests/prestataire_pending_request_card.dart';
import '../providers/dashboard/prestataire_dashboard_overview_provider.dart';
import '../providers/boutique/boutique_providers.dart';
import '../../../services/supabase/prestataire/subscription/prestataire_subscription_providers.dart';
import '../widgets/dashboard/content/prestataire_dashboard_overview_grid.dart';
import '../widgets/dashboard/content/prestataire_dashboard_boutique_card.dart';
import '../widgets/dashboard/content/prestataire_dashboard_reorderable_sections.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../widgets/profile/overview/layout/prestataire_profile_load_error.dart';
import '../widgets/workspace/prestataire_profile_completion_card.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';
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
    ref.invalidate(prestataireSubscriptionStatusProvider);
    ref.invalidate(ownBoutiqueSummaryProvider);
    await Future.wait([
      ref.read(prestataireProfileFormProvider.future),
      ref.read(prestataireAnalyticsProvider.future),
      ref.read(prestataireDashboardProvider.future),
      ref.read(prestataireDashboardLayoutProvider.future),
      ref.read(prestataireSubscriptionStatusProvider.future),
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
    ref.watch(prestataireSubscriptionStatusProvider);
    final profileAsync = ref.watch(prestataireProfileFormProvider);
    final horairesAsync = ref.watch(prestataireHorairesProvider);
    final dashboardAsync = ref.watch(prestataireDashboardProvider);
    final hasHoraires = horairesAsync.maybeWhen(
      data: (h) => h.isNotEmpty,
      orElse: () => false,
    );

    return PrestataireBrandScaffold(
      body: profileAsync.when(
          data: (data) {
            final showProfileCard = !data.isProfileFullyEnriched(
              hasHoraires: hasHoraires,
            );

            return PrestataireWorkspaceShell(
              title: ShellStrings.navPrestataireDashboard,
              subtitle: DiscPrestaWorkspace.dashboardWebSubtitle,
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
                    if (dashboardAsync.maybeWhen(
                      data: (data) => data.needsCompletion.isNotEmpty,
                      orElse: () => false,
                    ))
                      SliverToBoxAdapter(
                        child: _CompletionReminderBanner(
                          count: dashboardAsync.value!.needsCompletion.length,
                          onOpenAgenda: context.goPrestataireAgenda,
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: PrestataireDashboardOverviewGrid(),
                    ),
                    const SliverToBoxAdapter(
                      child: PrestataireDashboardBoutiqueCard(),
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
                        onMarkDone: (id) {
                          final target = items.firstWhere((e) => e.id == id);
                          _runAction(
                            id,
                            () => _actions.markDone(target),
                          );
                        },
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
            title: ShellStrings.navPrestataireDashboard,
            subtitle: DiscPrestaWorkspace.dashboardWebSubtitle,
            child: DiscoveryListSkeleton(rowCount: 4, rowHeight: 110),
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
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final busy = actingId == item.id;
        final isPending =
            clientReservationUiStatusFromStatut(item.statut) ==
                ClientReservationUiStatus.pending;

        if (isPending) {
          return PrestatairePendingRequestCard(
            item: item,
            busy: busy,
            onAccept: busy ? null : () => onAccept(item.id),
            onReject: busy ? null : () => onReject(item.id),
          );
        }

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

class _CompletionReminderBanner extends StatelessWidget {
  const _CompletionReminderBanner({
    required this.count,
    required this.onOpenAgenda,
  });

  final int count;
  final VoidCallback onOpenAgenda;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Material(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onOpenAgenda,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DiscPrestaAgenda.completionReminderTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DiscPrestaAgenda.completionReminderBody(count),
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
