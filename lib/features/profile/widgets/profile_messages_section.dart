import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import 'profile_section_title.dart';

/// Raccourci profil → onglet Messages.
class ProfileMessagesSection extends ConsumerWidget {
  const ProfileMessagesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(
      messagingUnreadCountProvider(MessagingInboxRole.client),
    ).value ?? 0;
    final subtitle = unread > 0
        ? '$unread chat${unread > 1 ? 's' : ''} non lu${unread > 1 ? 's' : ''}'
        : DiscChat.profileShortcutHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(title: DiscChat.profileSectionTitle),
        DiscoverySurfaceCard(
          child: DiscoveryMenuTile(
            icon: Icons.chat_bubble_rounded,
            title: DiscChat.profileShortcut,
            subtitle: subtitle,
            onTap: () => context.goClientMessages(),
          ),
        ),
      ],
    );
  }
}
