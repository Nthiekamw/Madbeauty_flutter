import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/profile/providers/profile_tab_visibility_provider.dart';
import '../../features/prestataire/providers/agenda/prestataire_agenda_provider.dart';
import '../../services/notifications/booking_reminders_sync.dart';
import '../../services/notifications/live_refresh.dart';
import '../../services/storage/local_cache_service.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/layout/adaptive_shell_scaffold.dart';
import '../../shared/widgets/layout/offline_shell.dart';
import 'prestataire_shell_destinations.dart';
import 'prestataire_shell_nav_bar.dart';

class PrestataireShellScaffold extends ConsumerStatefulWidget {
  const PrestataireShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<PrestataireShellScaffold> createState() =>
      _PrestataireShellScaffoldState();
}

class _PrestataireShellScaffoldState
    extends ConsumerState<PrestataireShellScaffold> {
  static const int dashboardTabIndex = 0;
  static const int agendaTabIndex = 1;
  static const int messagesTabIndex = 3;
  static const int profileTabIndex = 4;
  int? _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(LocalCacheService.instance.setSelectedRole('prestataire'));
      unawaited(LocalCacheService.instance.setSignupShellRole('prestataire'));
      final index = widget.navigationShell.currentIndex;
      if (index == dashboardTabIndex || index == agendaTabIndex) {
        unawaited(
          syncPrestataireBookingRemindersWithLoader(
            () => ref.read(prestataireAgendaProvider.future),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final messagesUnread = ref
            .watch(
              messagingUnreadCountProvider(MessagingInboxRole.prestataire),
            )
            .value ??
        0;
    final selectedIndex = navigationShell.currentIndex;

    if (_lastSelectedIndex != selectedIndex) {
      if (selectedIndex == profileTabIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(profileTabVisibleTickProvider.notifier).markVisible();
        });
      }
      if (selectedIndex == dashboardTabIndex ||
          selectedIndex == agendaTabIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(
          syncPrestataireBookingRemindersWithLoader(
            () => ref.read(prestataireAgendaProvider.future),
          ),
        );
        });
      }
      _lastSelectedIndex = selectedIndex;
    }

    final destinations =
        PrestataireShellDestinations.build(messagesBadge: messagesUnread);

    void onTab(int index) {
      if (index == messagesTabIndex) {
        refreshMessagingInbox(ref, role: MessagingInboxRole.prestataire);
      }
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    return AdaptiveShellScaffold(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTab,
      destinations: destinations,
      pageTitle: destinations[selectedIndex].label,
      railSpaceLabel: DiscPrestaWorkspace.railSpaceLabel,
      bottomNavigationBar: PrestataireShellNavBar(
        selectedIndex: selectedIndex,
        messagesUnread: messagesUnread,
        onSelected: onTab,
      ),
      body: OfflineShell(child: navigationShell),
    );
  }
}

