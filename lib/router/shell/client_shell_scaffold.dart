import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../services/supabase/booking/booking_service_providers.dart';
import '../../shared/widgets/offline_shell.dart';
import 'shell_nav_badge_icon.dart';

class ClientShellScaffold extends ConsumerWidget {
  const ClientShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int reservationsTabIndex = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(clientPendingReservationsCountProvider).value ?? 0;
    final selectedIndex = navigationShell.currentIndex;

    return Scaffold(
      body: OfflineShell(child: navigationShell),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index == reservationsTabIndex) {
            invalidateClientReservations(ref);
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == selectedIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: shellNavBadgeIcon(
              outlined: Icons.home_outlined,
              filled: Icons.home,
              selected: false,
            ),
            selectedIcon: shellNavBadgeIcon(
              outlined: Icons.home_outlined,
              filled: Icons.home,
              selected: true,
            ),
            label: ShellStrings.navClientHome,
          ),
          NavigationDestination(
            icon: shellNavBadgeIcon(
              outlined: Icons.search_outlined,
              filled: Icons.search,
              selected: false,
            ),
            selectedIcon: shellNavBadgeIcon(
              outlined: Icons.search_outlined,
              filled: Icons.search,
              selected: true,
            ),
            label: ShellStrings.navClientSearch,
          ),
          NavigationDestination(
            icon: shellNavBadgeIcon(
              outlined: Icons.event_outlined,
              filled: Icons.event,
              selected: false,
              badgeCount: pendingCount,
            ),
            selectedIcon: shellNavBadgeIcon(
              outlined: Icons.event_outlined,
              filled: Icons.event,
              selected: true,
              badgeCount: pendingCount,
            ),
            label: ShellStrings.navClientReservations,
          ),
          NavigationDestination(
            icon: shellNavBadgeIcon(
              outlined: Icons.person_outline,
              filled: Icons.person,
              selected: false,
            ),
            selectedIcon: shellNavBadgeIcon(
              outlined: Icons.person_outline,
              filled: Icons.person,
              selected: true,
            ),
            label: ShellStrings.navClientProfile,
          ),
        ],
      ),
    );
  }
}
