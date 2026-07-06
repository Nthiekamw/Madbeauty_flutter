import 'dart:async';



import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';



import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/messaging/message.dart';

import '../../../features/auth/providers/auth_notifier.dart';

import '../../booking/logic/booking_formatters.dart';
import '../../../services/notifications/live_refresh.dart';
import '../../../services/supabase/messaging/message_service.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../providers/message_provider.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';

import '../models/conversation_inbox_item.dart';

import '../logic/chat_message_moderator.dart';
import '../logic/chat_message_templates.dart';
import '../logic/messaging_viewer_role_inference.dart';
import '../widgets/chat/chat_composer.dart';
import '../widgets/chat/chat_message_list.dart';
import '../../trust/widgets/report_content_sheet.dart';
import '../../../services/supabase/trust/content_report_service.dart';
import '../widgets/chat/chat_screen_app_bar.dart';
import '../widgets/chat/chat_delete_confirmation.dart';
import '../models/chat_inbox_key.dart';



class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    this.conversationId,
    this.bookingId,
    this.viewerRole,
  }) : assert(
          conversationId != null || bookingId != null,
          'conversationId ou bookingId requis',
        );

  /// Fil de discussion (prioritaire).
  final String? conversationId;

  /// Réservation (deep link / push legacy) — résolu vers [conversationId].
  final String? bookingId;

  final MessagingInboxRole? viewerRole;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _attachingImage = false;
  bool _deleting = false;
  int _lastMessageCount = 0;
  ConversationInboxItem? _lastHeader;
  Timer? _presenceRefresh;
  String? _activeConversationId;

  ChatRouteKey get _routeKey => ChatRouteKey(
        conversationId: widget.conversationId,
        bookingId: widget.bookingId,
        viewerRole: _effectiveViewerRole,
      );

  MessagingInboxRole? get _effectiveViewerRole =>
      widget.viewerRole ?? messagingViewerRoleFromActiveShell();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _presenceRefresh = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mounted) return;
      ref.invalidate(chatInboxItemProvider(_routeKey));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    final conversationId = _activeConversationId;
    if (conversationId == null || conversationId.isEmpty) return;
    refreshMessagingInbox(ref);
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationId != widget.conversationId ||
        oldWidget.bookingId != widget.bookingId ||
        oldWidget.viewerRole != widget.viewerRole) {
      _lastHeader = null;
    }
  }

  @override

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _presenceRefresh?.cancel();
    _controller.dispose();

    _scrollController.dispose();
    refreshMessagingInbox(ref);

    super.dispose();

  }



  void _scrollToBottom({bool animated = true}) {

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (!mounted || !_scrollController.hasClients) return;

      final max = _scrollController.position.maxScrollExtent;

      if (animated) {

        _scrollController.animateTo(

          max,

          duration: const Duration(milliseconds: 280),

          curve: Curves.easeOutCubic,

        );

      } else {

        _scrollController.jumpTo(max);

      }

    });

  }



  List<String> _recentOutgoingMessages(
    List<Message> messages,
    String? userId,
  ) {
    if (userId == null) return const [];
    final mine = messages.where((m) => m.senderId == userId).toList();
    if (mine.length <= 1) return const [];
    final withoutLatest = mine.sublist(0, mine.length - 1);
    final tail = withoutLatest.length > 5
        ? withoutLatest.sublist(withoutLatest.length - 5)
        : withoutLatest;
    return tail.map((m) => m.content).toList();
  }

  Future<void> _syncReceipts(String conversationId) async {
    final service = ref.read(messageServiceProvider);
    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (service == null || user == null) return;

    await service.markAsRead(
      conversationId: conversationId,
      userId: user.id,
    );

    refreshMessagingInbox(ref);
  }



  Future<void> _markRead(String conversationId) async =>
      _syncReceipts(conversationId);

  Future<void> _send(String conversationId) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) return;

    final recentOutgoing = _recentOutgoingMessages(
      ref.read(messagesProvider(conversationId)).asData?.value ?? const [],
      user.id,
    );
    final moderation = ChatMessageModerator.analyze(
      text,
      context: ChatMessageModerationContext(
        recentOutgoingMessages: recentOutgoing,
      ),
    );
    if (moderation.isBlocked) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(
            Icons.shield_outlined,
            color: Theme.of(ctx).colorScheme.error,
            size: 28,
          ),
          title: Text(moderation.dialogTitle),
          content: Text(moderation.dialogBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(DiscChat.moderationDialogOk),
            ),
          ],
        ),
      );
      return;
    }

    final service = ref.read(messageServiceProvider);
    if (service == null) return;



    setState(() => _sending = true);

    try {
      await service.send(
        conversationId: conversationId,
        senderId: user.id,
        content: text,
      );
      _controller.clear();
      refreshMessagingInbox(ref);
    } on MessageValidationException catch (error) {
      if (mounted) {
        final result =
            ChatMessageModerationResult(violations: [error.violation]);
        AppSnackBar.show(context, message: result.bannerMessage);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, message: DiscChat.sendError);
      }
    } finally {

      if (mounted) setState(() => _sending = false);

    }

  }

  void _invalidateInbox() {
    refreshMessagingInbox(ref);
  }

  Future<void> _confirmDeleteChat(String conversationId) async {
    if (_deleting) return;
    final confirmed = await confirmChatDeletion(
      context,
      title: DiscChat.deleteChatTitle,
      body: DiscChat.deleteChatBody,
    );
    if (!confirmed || !mounted) return;

    final service = ref.read(messageServiceProvider);
    if (service == null) return;

    setState(() => _deleting = true);
    try {
      await service.deleteConversation(conversationId: conversationId);
      _invalidateInbox();
      if (!mounted) return;
      AppSnackBar.show(context, message: DiscChat.deleteChatSuccess);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscChat.deleteChatError,
        kind: AppSnackKind.error,
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _handleMessageLongPress(
    Message message,
    String conversationId,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(
                DiscChat.deleteMessageAction,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () => Navigator.of(ctx).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'delete' && mounted) {
      await _confirmDeleteMessage(message, conversationId);
    }
  }

  Future<void> _confirmDeleteMessage(
    Message message,
    String conversationId,
  ) async {
    if (_deleting) return;
    final confirmed = await confirmChatDeletion(
      context,
      title: DiscChat.deleteMessageTitle,
      body: DiscChat.deleteMessageBody,
    );
    if (!confirmed || !mounted) return;

    final service = ref.read(messageServiceProvider);
    if (service == null) return;

    setState(() => _deleting = true);
    try {
      await service.deleteMessage(
        messageId: message.id,
        conversationId: conversationId,
      );
      _invalidateInbox();
      if (!mounted) return;
      AppSnackBar.show(context, message: DiscChat.deleteMessageSuccess);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscChat.deleteMessageError,
        kind: AppSnackKind.error,
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _sendImage(String conversationId) async {
    if (_sending || _attachingImage) return;

    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (picked == null || !mounted) return;

    late final StorageUploadFile uploadFile;
    try {
      uploadFile = await StorageUploadFile.fromXFile(picked);
      StorageService.validateImageFile(uploadFile);
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, message: DiscChat.imagePickError);
      }
      return;
    }

    final storage = ref.read(storageServiceProvider);
    final messageService = ref.read(messageServiceProvider);
    if (storage == null || messageService == null) {
      if (mounted) {
        AppSnackBar.show(context, message: DiscChat.imagePickError);
      }
      return;
    }

    final thread = await messageService.getConversation(conversationId);
    if (thread == null) {
      if (mounted) {
        AppSnackBar.show(context, message: DiscChat.imagePickError);
      }
      return;
    }
    final storageBookingId = widget.bookingId?.trim().isNotEmpty == true
        ? widget.bookingId!
        : await messageService.resolveBookingContextForSend(thread);

    setState(() => _attachingImage = true);
    try {
      final imageUrl = await storage.uploadChatAttachment(
        userId: user.id,
        bookingId: storageBookingId,
        file: uploadFile,
      );
      await messageService.sendImage(
        conversationId: conversationId,
        senderId: user.id,
        imageUrl: imageUrl,
      );
      refreshMessagingInbox(ref);
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, message: DiscChat.imagePickError);
      }
    } finally {
      if (mounted) setState(() => _attachingImage = false);
    }
  }



  void _onMessagesUpdated(int count) {

    final isFirstLoad = _lastMessageCount == 0 && count > 0;

    final hasNewMessage = count > _lastMessageCount;

    _lastMessageCount = count;



    if (isFirstLoad) {

      _scrollToBottom(animated: false);

    } else if (hasNewMessage) {

      _scrollToBottom(animated: true);

    }

  }



  String? _headerSubtitle(ConversationInboxItem? header) {
    if (header == null) return null;

    final parts = <String>[];
    if (header.serviceName?.trim().isNotEmpty == true) {
      parts.add(header.serviceName!.trim());
    }
    if (header.reservationDate != null) {
      final local = header.reservationDate!.toLocal();
      parts.add(
        '${local.day}/${local.month} · ${formatBookingTime(local)}',
      );
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }



  @override
  Widget build(BuildContext context) {
    final convIdAsync = ref.watch(chatConversationIdProvider(_routeKey));
    return convIdAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(DiscChat.inboxTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(DiscChat.inboxTitle)),
        body: Center(
          child: DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: CoreStrings.networkErrorTitle,
            body: DiscChat.loadError,
            actionLabel: DiscList.retry,
            onAction: () =>
                ref.invalidate(chatConversationIdProvider(_routeKey)),
          ),
        ),
      ),
      data: (conversationId) => _buildChatBody(context, conversationId),
    );
  }

  Widget _buildChatBody(BuildContext context, String conversationId) {
    _activeConversationId = conversationId;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.colorScheme.surface;

    final userId = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value?.id,
      _ => null,
    };

    final headerAsync = ref.watch(chatInboxItemProvider(_routeKey));
    final messagesAsync = ref.watch(messagesProvider(conversationId));

    final headerForRole = headerAsync.asData?.value ?? _lastHeader;
    final isPresta = _effectiveViewerRole == MessagingInboxRole.prestataire;
    final quickTemplates = isPresta
        ? ChatMessageTemplates.prestataire
        : ChatMessageTemplates.client;

    ref.listen(messagesProvider(conversationId), (prev, next) {
      unawaited(_markRead(conversationId));
      final count = next.asData?.value.length;
      if (count != null) _onMessagesUpdated(count);
    });

    ref.listen(chatInboxItemProvider(_routeKey), (_, next) {
      final fresh = next.asData?.value;
      if (fresh != null && mounted) {
        setState(() => _lastHeader = fresh);
      }
    });



    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_markRead(conversationId));
    });



    final freshHeader = headerAsync.asData?.value;
    if (freshHeader != null) {
      _lastHeader = freshHeader;
    }
    final header = freshHeader ?? _lastHeader;



    return Scaffold(

      backgroundColor: isDark ? scaffoldBg : AppColors.lightSurface,

      appBar: ChatScreenAppBar(
        displayName: header?.peerDisplayName ?? DiscChat.inboxTitle,
        peerPrenom: header?.peerPrenom,
        peerNom: header?.peerNom,
        avatarUrl: header?.peerAvatarUrl,
        subtitle: _headerSubtitle(header),
        peerLastSeenAt: header?.peerLastSeenAt,
        useSalonName: header?.showSalonName ?? false,
        onReport: header == null
            ? null
            : () => showReportContentSheet(
                  context,
                  targetType: ContentReportTargetType.conversation,
                  targetId: header.conversation.id,
                ),
        onDeleteChat: () => _confirmDeleteChat(conversationId),
      ),

      body: ColoredBox(
        color: isDark ? scaffoldBg : AppColors.lightSurface,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Center(
                child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceFor(theme.brightness),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        DiscChat.moderationSafetyHint,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
            Expanded(
              child: messagesAsync.when(

              loading: () => const DiscoveryListSkeleton(
                rowCount: 6,
                rowHeight: 72,
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              ),

              error: (_, __) => Center(
                child: DiscoveryEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: CoreStrings.networkErrorTitle,
                  body: DiscChat.loadError,
                  iconColor: theme.colorScheme.error,
                  actionLabel: DiscList.retry,
                  onAction: () =>
                      ref.invalidate(messagesProvider(conversationId)),
                ),
              ),

              data: (messages) {

                return ChatMessageList(

                  messages: messages,

                  currentUserId: userId,

                  scrollController: _scrollController,

                  onDeleteMessage: userId == null
                      ? null
                      : (m) => _handleMessageLongPress(m, conversationId),

                );

              },

              ),
            ),
            ChatComposer(
              controller: _controller,
              sending: _sending,
              attachingImage: _attachingImage,
              onSend: () => _send(conversationId),
              onAttachImage: () => _sendImage(conversationId),
              quickReplyTemplates: quickTemplates,
              recentOutgoingMessages: _recentOutgoingMessages(
                messagesAsync.asData?.value ?? const [],
                userId,
              ),
            ),
          ],
        ),
      ),

    );

  }

}


