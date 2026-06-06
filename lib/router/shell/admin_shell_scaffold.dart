import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/providers/admin_pending_counts_provider.dart';
import '../../services/storage/local_cache_service.dart';
import '../../shared/widgets/layout/offline_shell.dart';
import 'admin_shell_nav_bar.dart';

class AdminShellScaffold extends ConsumerStatefulWidget {
  const AdminShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const int homeTabIndex = 0;
  static const int verificationsTabIndex = 1;
  static const int reportsTabIndex = 2;
  static const int profileTabIndex = 3;

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

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final selectedIndex = navigationShell.currentIndex;
    final pendingVerifications =
        ref.watch(adminPendingVerificationsCountProvider).value ?? 0;
    final pendingReports =
        ref.watch(adminPendingReportsCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: OfflineShell(child: navigationShell),
      bottomNavigationBar: AdminShellNavBar(
        selectedIndex: selectedIndex,
        verificationsBadgeCount: pendingVerifications,
        reportsBadgeCount: pendingReports,
        onTap: (index) {
          if (index == AdminShellScaffold.verificationsTabIndex) {
            ref.invalidate(adminPendingVerificationsCountProvider);
          }
          if (index == AdminShellScaffold.reportsTabIndex) {
            ref.invalidate(adminPendingReportsCountProvider);
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
