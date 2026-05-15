import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../logic/client_reservation_ui_status.dart';
import '../models/client_reservation_summary.dart';
import '../widgets/booking_message.dart';
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
    final reservationsAsync = ref.watch(clientReservationsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(DiscNav.myReservationsTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: DiscBk.tabFuture),
              Tab(text: DiscBk.tabPast),
            ],
          ),
        ),
        body: reservationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 48),
                BookingMessage(
                  icon: Icons.cloud_off_outlined,
                  title: DiscBk.listErrTitle,
                  message: DiscBk.listErrBody,
                ),
              ],
            ),
          ),
          data: (all) => TabBarView(
            children: [
              _tabList(
                items: _upcoming(all),
                emptyTitle:
                    DiscBk.emptyFutureTitle,
                emptyBody:
                    DiscBk.emptyFutureBody,
              ),
              _tabList(
                items: _past(all),
                emptyTitle:
                    DiscBk.emptyPastTitle,
                emptyBody: DiscBk.emptyPastBody,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ClientReservationSummary> _upcoming(List<ClientReservationSummary> all) {
    final now = DateTime.now();
    final out = all.where((r) => !r.dateHeure.isBefore(now)).toList()
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return out;
  }

  List<ClientReservationSummary> _past(List<ClientReservationSummary> all) {
    final now = DateTime.now();
    final out = all.where((r) => r.dateHeure.isBefore(now)).toList()
      ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return out;
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
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              emptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => context.goClientSearch(),
              child: const Text(
                DiscBk.browsePresta,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final ui = clientReservationUiStatusFromStatut(item.statut);
          final canCancel = clientReservationCanCancel(ui);
          return ClientReservationCard(
            item: item,
            cancelLoading: _cancellingId == item.id,
            onCancel: canCancel
                ? () => _confirmCancel(item)
                : null,
          );
        },
      ),
    );
  }
}
