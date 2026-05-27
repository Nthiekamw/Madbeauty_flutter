import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/app_router.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../shared/widgets/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery_surface_card.dart';

/// Raccourci profil prestataire → onglet Messages.
class PrestataireProfileMessagesTile extends ConsumerWidget {
  const PrestataireProfileMessagesTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref
            .watch(
              messagingUnreadCountProvider(MessagingInboxRole.prestataire),
            )
            .value ??
        0;
    final subtitle = unread > 0
        ? '$unread message${unread > 1 ? 's' : ''} non lu${unread > 1 ? 's' : ''}'
        : DiscChat.profileShortcutHint;

    return DiscoverySurfaceCard(
      child: DiscoveryMenuTile(
        icon: Icons.chat_bubble_rounded,
        title: DiscChat.profileShortcut,
        subtitle: subtitle,
        onTap: () => context.goNamed(AppRouteNames.prestataireMessages),
      ),
    );
  }
}
