import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/notifications/in_app_notifications_sheet.dart';
import '../../../shared/widgets/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery_empty_state.dart';
import '../../../shared/widgets/discovery_screen_header.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/current_prestataire_provider.dart';
import '../providers/prestataire_dashboard_provider.dart';
import '../providers/disponibilite_provider.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_profile_enrichment_banner.dart';
import '../widgets/prestataire_agenda_reservation_card.dart';
import '../widgets/prestataire_completeness_badge.dart';
import '../widgets/prestataire_dashboard_section.dart';
import '../widgets/prestataire_dashboard_stats_strip.dart';
import '../widgets/prestataire_profile_incomplete_banner.dart';
import '../widgets/prestataire_profile_load_error.dart';
import '../widgets/prestataire_salon_hero.dart';

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
    ref.invalidate(prestataireDashboardProvider);
    await Future.wait([
      ref.read(prestataireProfileFormProvider.future),
      ref.read(prestataireDashboardProvider.future),
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
    final currentPrestataire = switch (ref.watch(currentPrestataireProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return DiscoveryBrandScaffold(
      body: profileAsync.when(
        data: (data) {
          final currentName = currentPrestataire?.nomSalon?.trim();
          final title = currentName != null && currentName.isNotEmpty
              ? currentName
              : data.nomSalon.trim().isNotEmpty
              ? data.nomSalon.trim()
              : DiscNav.prestDashboard;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                DiscoveryScreenHeader(
                  title: DiscNav.prestDashboard,
                  subtitle: DiscPrestaDash.pageSubtitle,
                  action: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Consumer(
                      builder: (ctx, ref, _) {
                        final unread =
                            ref.watch(unreadInAppNotificationsCountProvider);
                        return NotificationBellButton(
                          compact: true,
                          unreadCount: unread,
                          tooltip: DiscHome.notificationsTooltip,
                          onPressed: () =>
                              showInAppNotificationsSheet(context, ref),
                        );
                      },
                    ),
                  ),
                ),
                PrestataireSalonHero(
                  title: title,
                  subtitle: data.isProfessionallyComplete
                      ? DiscPrestaDash.welcome
                      : DiscPrestaDash.profileMissing,
                  avatarUrl: data.avatarUrl,
                  trailing: PrestataireCompletenessBadge(
                    complete: data.isProfessionallyComplete,
                  ),
                ),
                if (!data.isProfessionallyComplete)
                  const PrestataireProfileIncompleteBanner(),
                if (data.isProfessionallyComplete &&
                    !data.isProfileFullyEnriched(hasHoraires: hasHoraires))
                  const PrestataireProfileEnrichmentBanner(),
                dashboardAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: DiscoveryEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: DiscPrestaDash.loadErr,
                      body: DiscList.pullDownHint,
                      iconColor: theme.colorScheme.error,
                      actionLabel: DiscList.retry,
                      onAction: () =>
                          ref.invalidate(prestataireDashboardProvider),
                    ),
                  ),
                  data: (dashboard) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      PrestataireDashboardStatsStrip(
                        pendingCount: dashboard.pending.length,
                        todayCount: dashboard.todayConfirmed.length,
                        weekCount: dashboard.weekConfirmed.length,
                      ),
                      const SizedBox(height: 16),
                      PrestataireDashboardSection(
                        icon: Icons.inbox_rounded,
                        title: DiscPrestaDash.pendingTitle,
                        subtitle: DiscPrestaDash.pendingEmpty,
                        badgeCount: dashboard.pending.length,
                        isEmpty: dashboard.pending.isEmpty,
                        emptyTitle: DiscPrestaDash.pendingEmptyTitle,
                        emptyMessage: DiscPrestaDash.pendingEmpty,
                        iconColor: theme.colorScheme.tertiary,
                        child: _ReservationTimeline(
                          items: dashboard.pending,
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
                      const SizedBox(height: 16),
                      PrestataireDashboardSection(
                        icon: Icons.today_rounded,
                        title: DiscPrestaDash.todayTitle,
                        subtitle: DiscPrestaDash.todayEmpty,
                        badgeCount: dashboard.todayConfirmed.length,
                        isEmpty: dashboard.todayConfirmed.isEmpty,
                        emptyTitle: DiscPrestaDash.todayEmptyTitle,
                        emptyMessage: DiscPrestaDash.todayEmpty,
                        child: _ReservationTimeline(
                          items: dashboard.todayConfirmed,
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
                      if (dashboard.weekConfirmed.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        PrestataireDashboardSection(
                          icon: Icons.date_range_rounded,
                          title: DiscPrestaDash.weekTitle,
                          badgeCount: dashboard.weekConfirmed.length,
                          iconColor: theme.colorScheme.secondary,
                          child: _ReservationTimeline(
                            items: dashboard.weekConfirmed,
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        error: (_, __) => PrestataireProfileLoadError(
          onRetry: () => ref.invalidate(prestataireProfileFormProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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
