import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../client/widgets/workspace/client_workspace_header.dart';
import '../../client/widgets/workspace/client_workspace_shell.dart';
import '../../prestataire/widgets/workspace/prestataire_profile_completion_card.dart';
import '../../prestataire/widgets/workspace/prestataire_brand_scaffold.dart';
import '../../prestataire/widgets/workspace/prestataire_workspace_shell.dart';
import '../models/conversation_inbox_item.dart';
import '../widgets/inbox/conversation_list_tile.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../widgets/inbox/conversations_empty_state.dart';

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
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: ClientWorkspaceShell(
            subtitle: DiscChat.inboxTitle,
            panelOverlap: -8,
            header: const ClientWorkspaceHeader(
              subtitle: DiscChat.inboxTitle,
              compact: true,
            ),
            child: GuestAccountPrompt(
            icon: Icons.chat_bubble_outline_rounded,
            title: DiscChat.inboxTitle,
            message: DiscChat.loginRequired,
            ),
          ),
        ),
      );
    }

    final inboxAsync = ref.watch(conversationsInboxProvider(widget.role));
    final totalUnread =
        ref.watch(messagingUnreadCountProvider(widget.role)).value ?? 0;

    final headerSubtitle = totalUnread > 0
        ? DiscChat.unreadCountLabel(totalUnread)
        : (widget.role == MessagingInboxRole.prestataire
            ? DiscPrestaWorkspace.messagesInboxSubtitle
            : DiscChat.emptyBodyClient);

    if (widget.role == MessagingInboxRole.client) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: ClientWorkspaceShell(
            subtitle: headerSubtitle,
            panelOverlap: -8,
            header: ClientWorkspaceHeader(
              subtitle: headerSubtitle,
              compact: true,
            ),
            child: RefreshIndicator(
              onRefresh: _refreshInbox,
              child: _buildInboxSlivers(context, theme, inboxAsync),
            ),
          ),
        ),
      );
    }

    return PrestataireBrandScaffold(
      body: PrestataireWorkspaceShell(
        onRefresh: _refreshInbox,
        headerSubtitle: headerSubtitle,
        showMessagesAction: false,
        child: RefreshIndicator(
          onRefresh: _refreshInbox,
          child: _buildInboxSlivers(context, theme, inboxAsync),
        ),
      ),
    );
  }

  Widget _buildInboxSlivers(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<ConversationInboxItem>> inboxAsync,
  ) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (widget.role == MessagingInboxRole.prestataire)
          const SliverToBoxAdapter(
            child: PrestataireProfileCompletionCard(),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              widget.role == MessagingInboxRole.prestataire ? 4 : 16,
              20,
              8,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.forum_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DiscChat.inboxTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.role == MessagingInboxRole.prestataire
                            ? DiscPrestaWorkspace.messagesInboxSubtitle
                            : DiscChat.profileShortcutHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ...inboxAsync.when(
          loading: () => [
            DiscoveryListSkeleton.asSliver(rowCount: 6, rowHeight: 76),
          ],
          error: (_, __) => [
            SliverFillRemaining(
              hasScrollBody: false,
              child: DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: DiscChat.loadError,
                iconColor: theme.colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: () =>
                    ref.invalidate(conversationsInboxProvider(widget.role)),
              ),
            ),
          ],
          data: (items) {
            if (items.isEmpty) {
              return [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ConversationsEmptyState(role: widget.role),
                ),
              ];
            }

            return [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ConversationListTile(
                      item: item,
                      onTap: () =>
                          _openChat(item.conversation.reservationId),
                    );
                  },
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Future<void> _refreshInbox() async {
    ref.invalidate(conversationsInboxProvider(widget.role));
    ref.invalidate(messagingUnreadCountProvider(widget.role));
    await ref.read(conversationsInboxProvider(widget.role).future);
  }

  Future<void> _openChat(String bookingId) async {
    await context.pushChat(
      bookingId,
      as: widget.role == MessagingInboxRole.client ? 'client' : 'prestataire',
    );
    if (!mounted) return;
    ref.invalidate(conversationsInboxProvider(widget.role));
    ref.invalidate(messagingUnreadCountProvider(widget.role));
  }
}
