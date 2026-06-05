import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/offline/offline_queue_helper.dart';
import '../../../services/offline/pending_offline_action.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../client/widgets/workspace/client_workspace_shell.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../logic/client_reservation_lists.dart';
import '../logic/client_reservation_ui_status.dart';
import '../models/client_reservation_summary.dart';
import '../../messaging/messaging_navigation.dart';
import '../../../services/notifications/booking_local_reminders.dart';
import '../widgets/client_reservation_card.dart';

class ClientReservationsScreen extends ConsumerStatefulWidget {
  const ClientReservationsScreen({super.key});

  @override
  ConsumerState<ClientReservationsScreen> createState() =>
      _ClientReservationsScreenState();
}

class _ClientReservationsScreenState
    extends ConsumerState<ClientReservationsScreen> {
  String? _cancellingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      invalidateClientReservations(ref);
    });
  }

  Future<void> _refresh() async {
    invalidateClientReservations(ref);
    final list = await ref.read(clientReservationsProvider.future);
    await _syncReminders(list);
  }

  Future<void> _syncReminders(List<ClientReservationSummary> list) async {
    await BookingLocalReminders.instance.syncForReservations(
      list
          .map(
            (r) => (
              id: r.id,
              dateHeure: r.dateHeure,
              title: r.serviceName ?? DiscBk.unknownSvc,
              statut: r.statut,
            ),
          )
          .toList(),
    );
  }

  Future<void> _confirmCancel(ClientReservationSummary item) async {
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(DiscBk.revokeAskTitle),
            content: const Text(DiscBk.revokeAskBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(CoreStrings.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(DiscBk.revokeYes),
              ),
            ],
          ),
        ) ??
        false;

    if (!ok || !mounted) return;

    final bookingService = ref.read(bookingServiceProvider);
    if (bookingService == null) {
      if (!mounted) return;
      AppSnackBar.error(context, DiscBk.revokeFail);
      return;
    }

    setState(() => _cancellingId = item.id);

    final queued = await enqueueIfOffline(
      ref: ref,
      context: context,
      action: PendingOfflineAction.create(
        type: OfflineActionType.bookingCancel,
        payload: {'reservationId': item.id},
      ),
    );
    if (queued) {
      if (mounted) {
        setState(() => _cancellingId = null);
        invalidateClientReservations(ref);
      }
      return;
    }

    try {
      await bookingService.cancel(item.id);
      if (!mounted) return;
      invalidateBookingDetail(ref, item.id);
      invalidateClientReservations(ref);
      await ref.read(clientReservationsProvider.future);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, DiscBk.revokeFail);
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Quand une réservation est créée/annulée depuis un autre écran (ex: après
    // confirmation de booking), le signal s'incrémente. On diffère l'invalidation
    // au prochain frame pour éviter un setState/invalidate pendant le layout.
    ref.listen(reservationsRefreshSignalProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.invalidate(clientReservationsProvider);
        ref.invalidate(clientPendingReservationsCountProvider);
      });
    });

    ref.listen(clientReservationsProvider, (_, next) {
      final list = next.asData?.value;
      if (list != null) {
        unawaited(_syncReminders(list));
      }
    });

    if (ref.watch(isGuestBrowsingProvider)) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: ClientWorkspaceShell(
            subtitle: DiscBk.reservationsSubtitle,
            child: GuestAccountPrompt(
              icon: Icons.event_outlined,
              title: AuthStrings.guestReservationsTitle,
              message: AuthStrings.guestReservationsBody,
            ),
          ),
        ),
      );
    }

    final reservationsAsync = ref.watch(clientReservationsProvider);

    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: ClientWorkspaceShell(
            subtitle: DiscBk.reservationsSubtitle,
            top: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: DiscoverySurfaceCard(
                padding: const EdgeInsets.all(5),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: theme.textTheme.labelLarge,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  tabs: [
                    Tab(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upcoming_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(DiscBk.tabFuture),
                        ],
                      ),
                    ),
                    Tab(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(DiscBk.tabPast),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: reservationsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    DiscoveryEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: DiscBk.listErrTitle,
                      body: DiscBk.listErrBody,
                      iconColor: theme.colorScheme.error,
                      actionLabel: DiscList.retry,
                      onAction: _refresh,
                    ),
                  ],
                ),
              ),
              data: (all) => TabBarView(
                children: [
                  _tabList(
                    items: clientUpcomingReservations(all),
                    emptyTitle: DiscBk.emptyFutureTitle,
                    emptyBody: DiscBk.emptyFutureBody,
                  ),
                  _tabList(
                    items: clientPastReservations(all),
                    emptyTitle: DiscBk.emptyPastTitle,
                    emptyBody: DiscBk.emptyPastBody,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabList({
    required List<ClientReservationSummary> items,
    required String emptyTitle,
    required String emptyBody,
  }) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            DiscoveryEmptyState(
              icon: Icons.event_busy_outlined,
              title: emptyTitle,
              body: emptyBody,
              actionLabel: DiscBk.browsePresta,
              onAction: () => context.goClientSearch(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final ui = clientReservationUiStatusFromStatut(item.statut);
          final canCancel = clientReservationCanCancel(ui);
          return ClientReservationCard(
            item: item,
            onTap: () => context.pushClientReservationDetail(item.id),
            cancelLoading: _cancellingId == item.id,
            onCancel: canCancel ? () => _confirmCancel(item) : null,
            onMessage: () => openChatForReservation(context, ref, item.id),
          );
        },
      ),
    );
  }
}
