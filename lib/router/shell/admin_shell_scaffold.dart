import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/providers/admin_pending_counts_provider.dart';
import '../../features/admin/providers/admin_user_support_provider.dart';
import '../../services/storage/local_cache_service.dart';
import '../../shared/widgets/layout/offline_shell.dart';
import 'admin_shell_nav_bar.dart';

class AdminShellScaffold extends ConsumerStatefulWidget {
  const AdminShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int homeTabIndex = 0;
  static const int moderationTabIndex = 1;
  static const int supportTabIndex = 2;
  static const int managementTabIndex = 3;
  static const int profileTabIndex = 4;

  @override
  ConsumerState<AdminShellScaffold> createState() => _AdminShellScaffoldState();
}

class _AdminShellScaffoldState extends ConsumerState<AdminShellScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(LocalCacheService.instance.setSelectedRole('admin'));
    });
  }

  void _refreshTabCounts(int index) {
    switch (index) {
      case AdminShellScaffold.moderationTabIndex:
        ref.invalidate(adminPendingVerificationsCountProvider);
        ref.invalidate(adminPendingReportsCountProvider);
      case AdminShellScaffold.supportTabIndex:
        ref.invalidate(adminPendingBugReportsCountProvider);
        ref.invalidate(adminUserSupportUnreadCountProvider);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final selectedIndex = navigationShell.currentIndex;
    final pendingVerifications =
        ref.watch(adminPendingVerificationsCountProvider).value ?? 0;
    final pendingReports =
        ref.watch(adminPendingReportsCountProvider).value ?? 0;
    final pendingBugs =
        ref.watch(adminPendingBugReportsCountProvider).value ?? 0;
    final supportUnread =
        ref.watch(adminUserSupportUnreadCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: OfflineShell(child: navigationShell),
      bottomNavigationBar: AdminShellNavBar(
        selectedIndex: selectedIndex,
        moderationBadgeCount: pendingVerifications + pendingReports,
        supportBadgeCount: pendingBugs + supportUnread,
        onTap: (index) {
          _refreshTabCounts(index);
          navigationShell.goBranch(
            index,
            initialLocation: index == selectedIndex,
          );
        },
      ),
    );
  }
}
