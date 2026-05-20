import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/offline/offline_queue_helper.dart';
import '../../../services/offline/pending_offline_action.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../../shared/widgets/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery_empty_state.dart';
import '../../../shared/widgets/discovery_screen_header.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../logic/client_reservation_ui_status.dart';
import '../models/client_reservation_summary.dart';
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

  Future<void> _refresh() async {
    invalidateClientReservations(ref);
    await ref.read(clientReservationsProvider.future);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(DiscBk.revokeFail)),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(DiscBk.revokeFail)),
      );
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(isGuestBrowsingProvider)) {
      return DiscoveryBrandScaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DiscoveryScreenHeader(
              title: DiscNav.myReservationsTitle,
              subtitle: DiscBk.reservationsSubtitle,
            ),
            Expanded(
              child: GuestAccountPrompt(
                icon: Icons.event_outlined,
                title: AuthStrings.guestReservationsTitle,
                message: AuthStrings.guestReservationsBody,
              ),
            ),
          ],
        ),
      );
    }

    final reservationsAsync = ref.watch(clientReservationsProvider);

    return DefaultTabController(
      length: 2,
      child: DiscoveryBrandScaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DiscoveryScreenHeader(
              title: DiscNav.myReservationsTitle,
              subtitle: DiscBk.reservationsSubtitle,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DiscoverySurfaceCard(
                padding: const EdgeInsets.all(6),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle:
                      Theme.of(context).textTheme.labelLarge,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  tabs: const [
                    Tab(text: DiscBk.tabFuture),
                    Tab(text: DiscBk.tabPast),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
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
                        iconColor: Theme.of(context).colorScheme.error,
                        actionLabel: DiscList.retry,
                        onAction: _refresh,
                      ),
                    ],
                  ),
                ),
                data: (all) => TabBarView(
                  children: [
                    _tabList(
                      items: _upcoming(all),
                      emptyTitle: DiscBk.emptyFutureTitle,
                      emptyBody: DiscBk.emptyFutureBody,
                    ),
                    _tabList(
                      items: _past(all),
                      emptyTitle: DiscBk.emptyPastTitle,
                      emptyBody: DiscBk.emptyPastBody,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ClientReservationSummary> _upcoming(List<ClientReservationSummary> all) {
    final now = DateTime.now();
    return all.where((r) => !r.dateHeure.isBefore(now)).toList()
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
  }

  List<ClientReservationSummary> _past(List<ClientReservationSummary> all) {
    final now = DateTime.now();
    return all.where((r) => r.dateHeure.isBefore(now)).toList()
      ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
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
            cancelLoading: _cancellingId == item.id,
            onCancel: canCancel ? () => _confirmCancel(item) : null,
          );
        },
      ),
    );
  }
}
