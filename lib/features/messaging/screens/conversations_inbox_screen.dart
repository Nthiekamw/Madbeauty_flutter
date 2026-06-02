import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../client/widgets/workspace/client_workspace_shell.dart';
import '../widgets/conversation_list_tile.dart';
import '../widgets/conversations_empty_state.dart';

/// Liste des conversations (onglet Messages).
class ConversationsInboxScreen extends ConsumerStatefulWidget {
  const ConversationsInboxScreen({
    super.key,
    required this.role,
  });

  final MessagingInboxRole role;

  @override
  ConsumerState<ConversationsInboxScreen> createState() =>
      _ConversationsInboxScreenState();
}

class _ConversationsInboxScreenState
    extends ConsumerState<ConversationsInboxScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final isGuest = ref.watch(isGuestBrowsingProvider);

    if (user == null || isGuest) {
      return DiscoveryBrandScaffold(
        body: ClientWorkspaceShell(
          subtitle: DiscChat.inboxTitle,
          child: GuestAccountPrompt(
            icon: Icons.chat_bubble_outline_rounded,
            title: DiscChat.inboxTitle,
            message: DiscChat.loginRequired,
          ),
        ),
      );
    }

    final inboxAsync = ref.watch(conversationsInboxProvider(widget.role));
    final totalUnread =
        ref.watch(messagingUnreadCountProvider(widget.role)).value ?? 0;

    final chatSubtitle = totalUnread > 0
        ? DiscChat.unreadCountLabel(totalUnread)
        : DiscChat.emptyBodyClient;

    final inboxBody = inboxAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _scrollableEmpty(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            DiscChat.loadError,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _scrollableEmpty(
            child: ConversationsEmptyState(role: widget.role),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _refreshInbox(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ConversationListTile(
                  item: item,
                  onTap: () => _openChat(item.conversation.reservationId),
                ),
              );
            },
          ),
        );
      },
    );

    if (widget.role == MessagingInboxRole.client) {
      return DiscoveryBrandScaffold(
        body: ClientWorkspaceShell(
          subtitle: chatSubtitle,
          child: inboxBody,
        ),
      );
    }

    return DiscoveryBrandScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DiscoveryScreenHeader(
            title: DiscChat.inboxTitle,
            subtitle: totalUnread > 0
                ? DiscChat.unreadCountLabel(totalUnread)
                : null,
          ),
          Expanded(child: inboxBody),
        ],
      ),
    );
  }

  Future<void> _refreshInbox() async {
    ref.invalidate(conversationsInboxProvider(widget.role));
    ref.invalidate(messagingUnreadCountProvider(widget.role));
    await ref.read(conversationsInboxProvider(widget.role).future);
  }

  Future<void> _openChat(String bookingId) async {
    await context.pushChat(bookingId);
    if (!mounted) return;
    ref.invalidate(conversationsInboxProvider(widget.role));
    ref.invalidate(messagingUnreadCountProvider(widget.role));
  }

  Widget _scrollableEmpty({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () => _refreshInbox(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(child: child),
            ),
          ),
        );
      },
    );
  }
}
