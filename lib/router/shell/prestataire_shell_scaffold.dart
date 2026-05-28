import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../services/storage/local_cache_service.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../../shared/widgets/offline_shell.dart';

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
  static const int messagesTabIndex = 3;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(LocalCacheService.instance.setSelectedRole('prestataire'));
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

    return Scaffold(
      body: OfflineShell(child: navigationShell),
      // Évite les retours à la ligne des labels (ex: "Dashboard")
      // quand l'utilisateur a une échelle de texte système élevée.
      bottomNavigationBar: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
        ),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          height: 66,
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            if (index == messagesTabIndex) {
              ref.invalidate(
                conversationsInboxProvider(MessagingInboxRole.prestataire),
              );
              ref.invalidate(
                messagingUnreadCountProvider(MessagingInboxRole.prestataire),
              );
            }
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: ShellStrings.navPrestataireDashboard,
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: ShellStrings.navPrestataireAgenda,
            ),
            const NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups),
              label: ShellStrings.navPrestataireClients,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: messagesUnread > 0,
                label: Text(
                  messagesUnread > 99 ? '99+' : '$messagesUnread',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: messagesUnread > 0,
                label: Text(
                  messagesUnread > 99 ? '99+' : '$messagesUnread',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(Icons.chat_bubble_rounded),
              ),
              label: ShellStrings.navPrestataireMessages,
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: ShellStrings.navPrestataireProfile,
            ),
          ],
        ),
      ),
    );
  }
}
