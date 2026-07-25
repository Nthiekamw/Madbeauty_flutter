import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/booking/providers/booking_session_providers.dart';
import '../../features/home/providers/home_feed_provider.dart';
import '../../services/notifications/booking_reminders_sync.dart';
import '../../services/notifications/live_refresh.dart';
import '../../services/storage/local_cache_service.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../../features/reviews/widgets/client_review_prompt_coordinator.dart';
import '../../shared/layout/adaptive_shell_scaffold.dart';
import '../../shared/widgets/layout/offline_shell.dart';
import 'client_shell_destinations.dart';
import 'client_shell_nav_bar.dart';

class ClientShellScaffold extends ConsumerStatefulWidget {
  const ClientShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int homeTabIndex = 0;
  static const int reelTabIndex = 2;
  static const int messagesTabIndex = 3;
  static const int profileTabIndex = 4;

  @override
  ConsumerState<ClientShellScaffold> createState() => _ClientShellScaffoldState();
}

class _ClientShellScaffoldState extends ConsumerState<ClientShellScaffold> {
  int? _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(LocalCacheService.instance.setSelectedRole('client'));
      unawaited(LocalCacheService.instance.setSignupShellRole('client'));
      if (widget.navigationShell.currentIndex ==
          ClientShellScaffold.homeTabIndex) {
        unawaited(
          syncClientBookingRemindersWithLoader(
            () => ref.read(clientReservationsProvider.future),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final pendingCount = ref.watch(
      clientPendingReservationsCountProvider.select((a) => a.value ?? 0),
    );
    final messagesUnread = ref.watch(
      messagingUnreadCountProvider(MessagingInboxRole.client)
          .select((a) => a.value ?? 0),
    );
    final selectedIndex = widget.navigationShell.currentIndex;

    if (_lastSelectedIndex != selectedIndex) {
      if (selectedIndex == ClientShellScaffold.homeTabIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_lastSelectedIndex != null &&
              _lastSelectedIndex != ClientShellScaffold.homeTabIndex) {
            ref.read(homeFeedSelectionProvider.notifier).clear();
          }
          unawaited(
            syncClientBookingRemindersWithLoader(
              () => ref.read(clientReservationsProvider.future),
            ),
          );
        });
      }
      _lastSelectedIndex = selectedIndex;
    }

    final destinations = ClientShellDestinations.build(
      profileBadge: pendingCount,
      messagesBadge: messagesUnread,
    );

    void onTab(int index) {
      if (index == ClientShellScaffold.messagesTabIndex) {
        refreshMessagingInbox(ref, role: MessagingInboxRole.client);
      }
      navigationShell.goBranch(
        index,
        initialLocation: index == selectedIndex,
      );
    }

    return AdaptiveShellScaffold(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTab,
      destinations: destinations,
      pageTitle: destinations[selectedIndex].label,
      bottomNavigationBar: ClientShellNavBar(
        selectedIndex: selectedIndex,
        profileBadgeCount: pendingCount,
        messagesBadgeCount: messagesUnread,
        onTap: onTab,
      ),
      body: ClientReviewPromptCoordinator(
        child: OfflineShell(child: navigationShell),
      ),
    );
  }
}

