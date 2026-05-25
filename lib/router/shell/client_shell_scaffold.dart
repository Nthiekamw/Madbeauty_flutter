import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/supabase/booking/booking_service_providers.dart';
import '../../shared/widgets/offline_shell.dart';
import 'client_shell_bottom_nav.dart';

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
      bottomNavigationBar: SafeArea(
        top: false,
        child: ClientShellBottomNav(
          selectedIndex: selectedIndex,
          reservationsBadgeCount: pendingCount,
          onTap: (index) {
            if (index == reservationsTabIndex) {
              invalidateClientReservations(ref);
            }
            navigationShell.goBranch(
              index,
              initialLocation: index == selectedIndex,
            );
          },
        ),
      ),
    );
  }
}
