import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../services/supabase/messaging/messaging_providers.dart';
import '../../../../shared/widgets/discovery/discovery_empty_state.dart';

/// État vide de l'inbox messagerie (texte selon le rôle).
class ConversationsEmptyState extends StatelessWidget {
  const ConversationsEmptyState({
    super.key,
    required this.role,
  });

  final MessagingInboxRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isClient = role == MessagingInboxRole.client;

    return DiscoveryEmptyState(
      icon: Icons.chat_bubble_outline_rounded,
      title: DiscChat.emptyTitle,
      body: isClient ? DiscChat.emptyBodyClient : DiscChat.emptyBodyPresta,
      iconColor: theme.colorScheme.primary,
    );
  }
}

