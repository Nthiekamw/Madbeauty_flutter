import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/app_router.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../auth/widgets/role_switch_section.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../providers/current_prestataire_provider.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/prestataire_dashboard_provider.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_appointment_tile.dart';
import '../widgets/prestataire_dashboard_section.dart';
import '../widgets/prestataire_pending_request_card.dart';
import '../widgets/prestataire_profile_load_error.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscNav.prestDashboard),
      ),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppAvatar(
                      imageUrl: data.avatarUrl,
                      displayName: title,
                      radius: 36,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.isProfessionallyComplete
                                ? DiscPrestaDash.welcome
                                : DiscPrestaDash.profileMissing,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      context.goNamed(AppRouteNames.prestataireProfile),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text(DiscPrestaDash.editProfile),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.pushPrestataireHoraires(),
                  icon: const Icon(Icons.schedule_outlined),
                  label: const Text(DiscPrestaDash.editHoraires),
                ),
                const SizedBox(height: 8),
                const RoleSwitchSection(sectionTitle: DiscNav.profileSpace),
                const SizedBox(height: 24),
                dashboardAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => Text(
                    DiscPrestaDash.loadErr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  data: (dashboard) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PrestataireDashboardSection(
                        title: DiscPrestaDash.pendingTitle,
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
                      const SizedBox(height: 24),
                      PrestataireDashboardSection(
                        title: DiscPrestaDash.todayTitle,
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
                        const SizedBox(height: 24),
                        PrestataireDashboardSection(
                          title: DiscPrestaDash.weekTitle,
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
              child: Text(
                busy ? '…' : DiscPrestaAgenda.markDone,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
