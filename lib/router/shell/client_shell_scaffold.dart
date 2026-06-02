import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/storage/local_cache_service.dart';
import '../../services/supabase/booking/booking_service_providers.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../../features/reviews/widgets/client_review_prompt_coordinator.dart';
import '../../shared/widgets/layout/offline_shell.dart';
import 'client_shell_nav_bar.dart';

class ClientShellScaffold extends ConsumerStatefulWidget {
  const ClientShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int reservationsTabIndex = 2;
  static const int messagesTabIndex = 3;
  static const int profileTabIndex = 4;

  @override
  ConsumerState<ClientShellScaffold> createState() => _ClientShellScaffoldState();
}

class _ClientShellScaffoldState extends ConsumerState<ClientShellScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(LocalCacheService.instance.setSelectedRole('client'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final pendingCount = ref.watch(clientPendingReservationsCountProvider).value ?? 0;
    final messagesUnread =
        ref.watch(messagingUnreadCountProvider(MessagingInboxRole.client)).value ??
            0;
    final selectedIndex = widget.navigationShell.currentIndex;

    return Scaffold(
      body: ClientReviewPromptCoordinator(
        child: OfflineShell(child: navigationShell),
      ),
      bottomNavigationBar: ClientShellNavBar(
          selectedIndex: selectedIndex,
          reservationsBadgeCount: pendingCount,
          messagesBadgeCount: messagesUnread,
          onTap: (index) {
            if (index == ClientShellScaffold.reservationsTabIndex) {
              invalidateClientReservations(ref);
            }
            if (index == ClientShellScaffold.messagesTabIndex) {
              ref.invalidate(conversationsInboxProvider(MessagingInboxRole.client));
              ref.invalidate(
                messagingUnreadCountProvider(MessagingInboxRole.client),
              );
            }
            navigationShell.goBranch(
              index,
              initialLocation: index == selectedIndex,
            );
          },
        ),
    );
  }
}
