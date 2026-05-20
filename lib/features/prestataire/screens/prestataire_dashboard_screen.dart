import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery_screen_header.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/current_prestataire_provider.dart';
import '../providers/prestataire_dashboard_provider.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_appointment_tile.dart';
import '../widgets/prestataire_dashboard_section.dart';
import '../widgets/prestataire_pending_request_card.dart';
import '../widgets/prestataire_profile_load_error.dart';
import '../widgets/prestataire_profile_manage_menu.dart';
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
    final profileAsync = ref.watch(prestataireProfileFormProvider);
    final dashboardAsync = ref.watch(prestataireDashboardProvider);
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
                const DiscoveryScreenHeader(
                  title: DiscNav.prestDashboard,
                  subtitle: DiscPrestaDash.pageSubtitle,
                ),
                PrestataireSalonHero(
                  title: title,
                  subtitle: data.isProfessionallyComplete
                      ? DiscPrestaDash.welcome
                      : DiscPrestaDash.profileMissing,
                  avatarUrl: data.avatarUrl,
                  trailing: _CompletenessBadge(
                    complete: data.isProfessionallyComplete,
                  ),
                ),
                const SizedBox(height: 16),
                PrestataireProfileManageMenu(
                  showHeader: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                if (!data.isProfessionallyComplete) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton(
                      onPressed: () => context.pushPrestataireProfileComplete(),
                      child: const Text(DiscPrestaProfile.incompleteCta),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                dashboardAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      DiscPrestaDash.loadErr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  data: (dashboard) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PrestataireDashboardSection(
                        title: DiscPrestaDash.pendingTitle,
                        badgeCount: dashboard.pending.length,
                        child: dashboard.pending.isEmpty
                            ? const PrestataireDashboardEmptyHint(
                                message: DiscPrestaDash.pendingEmpty,
                              )
                            : Column(
                                children: [
                                  for (final item in dashboard.pending)
                                    PrestatairePendingRequestCard(
                                      item: item,
                                      busy: _actingReservationId == item.id,
                                      onAccept: _actingReservationId != null
                                          ? null
                                          : () => _runAction(
                                              item.id,
                                              () => _actions.accept(item.id),
                                            ),
                                      onReject: _actingReservationId != null
                                          ? null
                                          : () => _runAction(
                                              item.id,
                                              () => _actions.reject(item.id),
                                            ),
                                    ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      PrestataireDashboardSection(
                        title: DiscPrestaDash.todayTitle,
                        badgeCount: dashboard.todayConfirmed.length,
                        child: dashboard.todayConfirmed.isEmpty
                            ? const PrestataireDashboardEmptyHint(
                                message: DiscPrestaDash.todayEmpty,
                              )
                            : Column(
                                children: [
                                  for (final item in dashboard.todayConfirmed)
                                    _TodayAppointment(
                                      item: item,
                                      busy: _actingReservationId == item.id,
                                      onMarkDone:
                                          _actingReservationId != null
                                          ? null
                                          : () => _runAction(
                                              item.id,
                                              () => _actions.markDone(item.id),
                                            ),
                                    ),
                                ],
                              ),
                      ),
                      if (dashboard.weekConfirmed.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        PrestataireDashboardSection(
                          title: DiscPrestaDash.weekTitle,
                          badgeCount: dashboard.weekConfirmed.length,
                          child: Column(
                            children: [
                              for (final item in dashboard.weekConfirmed)
                                PrestataireAppointmentTile(
                                  item: item,
                                  showDate: true,
                                ),
                            ],
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

class _CompletenessBadge extends StatelessWidget {
  const _CompletenessBadge({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: complete
            ? theme.colorScheme.primary.withValues(alpha: 0.14)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            complete ? Icons.check_circle_outline : Icons.info_outline,
            size: 16,
            color: complete
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          const SizedBox(width: 6),
          Text(
            complete ? 'Profil complet' : 'À compléter',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: complete
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayAppointment extends StatelessWidget {
  const _TodayAppointment({
    required this.item,
    required this.onMarkDone,
    this.busy = false,
  });

  final PrestataireReservationItem item;
  final VoidCallback? onMarkDone;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireAppointmentTile(item: item),
        if (clientReservationUiStatusFromStatut(item.statut) ==
            ClientReservationUiStatus.confirmed) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: busy ? null : onMarkDone,
              child: Text(busy ? '…' : DiscPrestaAgenda.markDone),
            ),
          ),
        ],
      ],
    );
  }
}
