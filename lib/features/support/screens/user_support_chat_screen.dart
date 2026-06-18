import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/auth/providers/my_roles_provider.dart';
import '../../../core/models/user_role.dart';
import '../../../services/supabase/support/user_support_providers.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../messaging/logic/chat_message_receipt.dart';
import '../../messaging/widgets/chat/chat_bubble.dart';
import '../../messaging/widgets/chat/chat_composer.dart';

/// Fil de chat support entre un utilisateur et l’admin.
class UserSupportChatScreen extends ConsumerWidget {
  const UserSupportChatScreen({super.key, this.threadId});

  /// Fil explicite (admin). Sinon, le fil de l’utilisateur connecté est créé.
  final String? threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (threadId != null) {
      return _UserSupportChatBody(threadId: threadId!);
    }

    final threadAsync = ref.watch(myUserSupportThreadIdProvider);
    return threadAsync.when(
      data: (id) => _UserSupportChatBody(threadId: id),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text(DiscSupport.screenTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: const Text(DiscSupport.screenTitle)),
        body: Center(
          child: Text(
            DiscSupport.loadErr,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}

class _UserSupportChatBody extends ConsumerStatefulWidget {
  const _UserSupportChatBody({required this.threadId});

  final String threadId;

  @override
  ConsumerState<_UserSupportChatBody> createState() =>
      _UserSupportChatBodyState();
}

class _UserSupportChatBodyState extends ConsumerState<_UserSupportChatBody> {
  final _composer = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncReceipts());
    });
  }

  Future<void> _syncReceipts() async {
    final service = ref.read(userSupportMessageServiceProvider);
    final userId = ref.read(authNotifierProvider).maybeWhen(
          data: (u) => u?.id,
          orElse: () => null,
        );
    if (service == null || userId == null) return;
    await service.markAsRead(
      threadId: widget.threadId,
      userId: userId,
    );
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final service = ref.read(userSupportMessageServiceProvider);
    if (service == null) return;
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await service.send(threadId: widget.threadId, content: text);
      _composer.clear();
      ref.invalidate(userSupportMessagesProvider(widget.threadId));
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscSupport.sendErr);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final messagesAsync =
        ref.watch(userSupportMessagesProvider(widget.threadId));
    final currentUserId = ref.watch(authNotifierProvider).maybeWhen(
          data: (u) => u?.id,
          orElse: () => null,
        );
    final isAdmin =
        ref.watch(myRolesProvider).value?.contains(UserRole.admin) ?? false;
    final timeFormat = DateFormat('HH:mm', 'fr_FR');

    ref.listen(userSupportMessagesProvider(widget.threadId), (_, __) {
      unawaited(_syncReceipts());
    });

    return Scaffold(
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : AppColors.lightSurfaceContainer,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? DiscSupport.screenTitleAdmin : DiscSupport.screenTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              DiscSupport.subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.adminAccentMid,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        flexibleSpace: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.adminAccent.withValues(alpha: isDark ? 0.14 : 0.1),
                theme.colorScheme.surface.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return DiscoveryEmptyState(
                    icon: Icons.support_agent_rounded,
                    title: DiscSupport.emptyTitle,
                    body: isAdmin
                        ? DiscSupport.emptyBodyAdmin
                        : DiscSupport.emptyBody,
                    iconColor: AppColors.adminAccentMid,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == currentUserId;
                    return ChatBubble(
                      text: message.content,
                      isMine: isMine,
                      receiptStatus: isMine
                          ? chatOutgoingReceiptStatus(
                              isRead: message.isRead,
                              deliveredAt: message.deliveredAt,
                            )
                          : null,
                      timeLabel: timeFormat.format(message.createdAt.toLocal()),
                    );
                  },
                );
              },
              loading: () => const DiscoveryListSkeleton(
                rowCount: 4,
                rowHeight: 56,
                padding: EdgeInsets.all(16),
              ),
              error: (_, __) => Center(
                child: Text(
                  DiscSupport.loadErr,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: ChatComposer(
                controller: _composer,
                sending: _sending,
                onSend: _send,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
