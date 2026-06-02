import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/storage/local_cache_service.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../../shared/widgets/layout/offline_shell.dart';
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
      bottomNavigationBar: PrestataireShellNavBar(
        selectedIndex: navigationShell.currentIndex,
        messagesUnread: messagesUnread,
        onSelected: (index) {
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
      ),
    );
  }
}
