import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/profile_flow_scaffold.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../messaging/messaging_navigation.dart';
import '../../messaging/models/messaging_inbox_role.dart';
import '../logic/client_reservation_lists.dart';
import '../models/client_reservation_summary.dart';
import '../widgets/reservation/client_reservation_card.dart';

class ClientHistoryScreen extends ConsumerStatefulWidget {
  const ClientHistoryScreen({super.key});

  @override
  ConsumerState<ClientHistoryScreen> createState() =>
      _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends ConsumerState<ClientHistoryScreen> {
  Future<void> _refresh() async {
    ref.invalidate(clientReservationsProvider);
    await ref.read(clientReservationsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(isGuestBrowsingProvider)) {
      return ProfileFlowScaffold(
        title: DiscProfile.historyTitle,
        subtitle: DiscProfile.historySubtitle,
        icon: Icons.history_rounded,
        wrapPanel: false,
        body: GuestAccountPrompt(
          icon: Icons.history_rounded,
          title: AuthStrings.guestReservationsTitle,
          message: AuthStrings.guestReservationsBody,
        ),
      );
    }

    final reservationsAsync = ref.watch(clientReservationsProvider);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;

    return ProfileFlowScaffold(
      title: DiscProfile.historyTitle,
      subtitle: DiscProfile.historySubtitle,
      icon: Icons.history_rounded,
      body: reservationsAsync.when(
        loading: () => const DiscoveryListSkeleton(rowCount: 4, rowHeight: 120),
        error: (_, __) => RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: DiscBk.listErrBody,
                iconColor: Theme.of(context).colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: _refresh,
              ),
            ],
          ),
        ),
        data: (all) => _HistoryList(
          items: clientPastReservations(all),
          onRefresh: _refresh,
          onMessage: (id) => openChatForReservation(
                context,
                ref,
                id,
                viewerRole: MessagingInboxRole.client,
              ),
          listPadding: useWeb
              ? const EdgeInsets.fromLTRB(20, 16, 20, 24)
              : const EdgeInsets.fromLTRB(20, 8, 20, 24),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.items,
    required this.onRefresh,
    required this.onMessage,
    required this.listPadding,
  });

  final List<ClientReservationSummary> items;
  final Future<void> Function() onRefresh;
  final void Function(String reservationId) onMessage;
  final EdgeInsets listPadding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            DiscoveryEmptyState(
              icon: Icons.history_rounded,
              title: DiscBk.emptyPastTitle,
              body: DiscBk.emptyPastBody,
              actionLabel: DiscBk.browsePresta,
              onAction: () => context.goClientSearch(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: listPadding,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return ClientReservationCard(
            item: item,
            onTap: () => context.pushClientReservationDetail(item.id),
            onMessage: () => onMessage(item.id),
            onReviewSubmitted: onRefresh,
          );
        },
      ),
    );
  }
}
