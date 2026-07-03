import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/notifications/live_refresh.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../client/widgets/workspace/client_workspace_header.dart';
import '../../client/widgets/workspace/client_workspace_shell.dart';
import '../../prestataire/widgets/workspace/prestataire_profile_completion_card.dart';
import '../../prestataire/widgets/workspace/prestataire_brand_scaffold.dart';
import '../../prestataire/widgets/workspace/prestataire_workspace_shell.dart';
import '../../home/widgets/shared/client_home_section_header.dart';
import '../../prestataire/widgets/shared/prestataire_section_header.dart';
import '../models/conversation_inbox_item.dart';
import '../widgets/inbox/conversation_list_tile.dart';
import '../../../shared/layout/adaptive_safe_area.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../widgets/inbox/conversations_empty_state.dart';
import '../widgets/chat/chat_delete_confirmation.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';

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
        body: AdaptiveSafeArea(
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
            ? DiscPrestaWorkspace.messagesInboxHeaderSubtitle
            : DiscChat.inboxHeaderSubtitleClient);

    if (widget.role == MessagingInboxRole.client) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: AdaptiveSafeArea(
          child: ClientWorkspaceShell(
            title: ShellStrings.navClientMessages,
            subtitle: headerSubtitle,
            panelOverlap: -8,
            header: ClientWorkspaceHeader(
              subtitle: headerSubtitle,
              compact: true,
            ),
            child: RefreshIndicator(
              onRefresh: _refreshInbox,
              child: _buildInboxSlivers(context, theme, inboxAsync, headerSubtitle),
            ),
          ),
        ),
      );
    }

    return PrestataireBrandScaffold(
      body: PrestataireWorkspaceShell(
        title: ShellStrings.navPrestataireMessages,
        subtitle: headerSubtitle,
        onRefresh: _refreshInbox,
        headerSubtitle: headerSubtitle,
        showMessagesAction: false,
        child: RefreshIndicator(
          onRefresh: _refreshInbox,
          child: _buildInboxSlivers(context, theme, inboxAsync, headerSubtitle),
        ),
      ),
    );
  }

  Widget _buildInboxSlivers(
    BuildContext context,
    ThemeData theme,
    AsyncValue<List<ConversationInboxItem>> inboxAsync,
    String headerSubtitle,
  ) {
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final hPad = useWeb ? 16.0 : 20.0;

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
              hPad,
              widget.role == MessagingInboxRole.prestataire ? 4 : 12,
              hPad,
              8,
            ),
            child: widget.role == MessagingInboxRole.client
                ? (DiscoveryResponsive.of(context).useWebSiteLayout
                    ? const SizedBox.shrink()
                    : ClientHomeSectionHeader(
                        title: DiscChat.inboxTitle,
                        subtitle: headerSubtitle,
                        icon: Icons.forum_rounded,
                      ))
                : (useWeb
                    ? const SizedBox.shrink()
                    : PrestataireSectionHeader(
                        icon: Icons.forum_rounded,
                        title: DiscChat.inboxTitle,
                        subtitle: DiscPrestaWorkspace.messagesInboxSubtitle,
                      )),
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
                padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 24),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ConversationListTile(
                      item: item,
                      onTap: () =>
                          _openChat(item.conversation.id),
                      onLongPress: () => _confirmDeleteChat(
                        item.conversation.id,
                      ),
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
    refreshMessagingInbox(ref, role: widget.role);
    await ref.read(conversationsInboxProvider(widget.role).future);
  }

  Future<void> _openChat(String conversationId) async {
    await context.pushChat(
      conversationId,
      as: widget.role == MessagingInboxRole.client ? 'client' : 'prestataire',
    );
    if (!mounted) return;
    refreshMessagingInbox(ref, role: widget.role);
  }

  Future<void> _confirmDeleteChat(String conversationId) async {
    final confirmed = await confirmChatDeletion(
      context,
      title: DiscChat.deleteChatTitle,
      body: DiscChat.deleteChatBody,
    );
    if (!confirmed || !mounted) return;

    final service = ref.read(messageServiceProvider);
    if (service == null) return;

    try {
      await service.deleteConversation(conversationId: conversationId);
      ref.invalidate(conversationsInboxProvider(widget.role));
      ref.invalidate(messagingUnreadCountProvider(widget.role));
      if (!mounted) return;
      AppSnackBar.show(context, message: DiscChat.deleteChatSuccess);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscChat.deleteChatError,
        kind: AppSnackKind.error,
      );
    }
  }
}
