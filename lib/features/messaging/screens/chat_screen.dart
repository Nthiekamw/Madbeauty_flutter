import 'dart:async';



import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';



import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/messaging/message.dart';

import '../../../features/auth/providers/auth_notifier.dart';

import '../../booking/logic/booking_formatters.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../services/supabase/messaging/message_service.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../providers/message_provider.dart';

import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';

import '../models/conversation_inbox_item.dart';

import '../logic/chat_message_moderator.dart';
import '../logic/chat_message_templates.dart';
import '../widgets/chat/chat_composer.dart';
import '../widgets/chat/chat_message_list.dart';
import '../../trust/widgets/report_content_sheet.dart';
import '../../../services/supabase/trust/content_report_service.dart';
import '../widgets/chat/chat_screen_app_bar.dart';
import '../widgets/chat/chat_delete_confirmation.dart';
import '../models/chat_inbox_key.dart';
import '../providers/messaging_inbox_providers.dart';



class ChatScreen extends ConsumerStatefulWidget {

  const ChatScreen({super.key, required this.bookingId, this.viewerRole});

  /// Identifiant de la réservation (booking).
  final String bookingId;

  /// Rôle dans le fil (client → salon ; prestataire → cliente).
  final MessagingInboxRole? viewerRole;



  @override

  ConsumerState<ChatScreen> createState() => _ChatScreenState();

}



class _ChatScreenState extends ConsumerState<ChatScreen> {

  final _controller = TextEditingController();

  final _scrollController = ScrollController();

  bool _sending = false;
  bool _attachingImage = false;
  bool _deleting = false;

  int _lastMessageCount = 0;
  ConversationInboxItem? _lastHeader;
  Timer? _presenceRefresh;



  ChatInboxKey get _inboxKey => ChatInboxKey(
        bookingId: widget.bookingId,
        viewerRole: widget.viewerRole,
      );

  @override
  void initState() {
    super.initState();
    _presenceRefresh = Timer.periodic(const Duration(seconds: 45), (_) {
      if (!mounted) return;
      ref.invalidate(chatInboxItemProvider(_inboxKey));
    });
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bookingId != widget.bookingId ||
        oldWidget.viewerRole != widget.viewerRole) {
      _lastHeader = null;
    }
  }

  @override

  void dispose() {
    _presenceRefresh?.cancel();
    _controller.dispose();

    _scrollController.dispose();

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

  Future<void> _syncReceipts() async {

    final service = ref.read(messageServiceProvider);

    final user = switch (ref.read(authNotifierProvider)) {

      AsyncData(:final value) => value,

      _ => null,

    };

    if (service == null || user == null) return;

    await service.markAsRead(

      bookingId: widget.bookingId,

      userId: user.id,

    );

    ref.invalidate(messagingUnreadCountProvider(MessagingInboxRole.client));

    ref.invalidate(messagingUnreadCountProvider(MessagingInboxRole.prestataire));

    ref.invalidate(conversationsInboxProvider(MessagingInboxRole.client));

    ref.invalidate(conversationsInboxProvider(MessagingInboxRole.prestataire));

  }



  Future<void> _markRead() async => _syncReceipts();



  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) return;

    final recentOutgoing = _recentOutgoingMessages(
      ref.read(messagesProvider(widget.bookingId)).asData?.value ?? const [],
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
        bookingId: widget.bookingId,
        senderId: user.id,
        content: text,
      );
      _controller.clear();
      ref.invalidate(conversationsInboxProvider(MessagingInboxRole.client));
      ref.invalidate(conversationsInboxProvider(MessagingInboxRole.prestataire));
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
    ref.invalidate(conversationsInboxProvider(MessagingInboxRole.client));
    ref.invalidate(conversationsInboxProvider(MessagingInboxRole.prestataire));
    ref.invalidate(messagingUnreadCountProvider(MessagingInboxRole.client));
    ref.invalidate(messagingUnreadCountProvider(MessagingInboxRole.prestataire));
  }

  Future<void> _confirmDeleteChat() async {
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
      await service.deleteChat(bookingId: widget.bookingId);
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

  Future<void> _handleMessageLongPress(Message message) async {
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
      await _confirmDeleteMessage(message);
    }
  }

  Future<void> _confirmDeleteMessage(Message message) async {
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
        bookingId: widget.bookingId,
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

  Future<void> _sendImage() async {
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

    setState(() => _attachingImage = true);
    try {
      final imageUrl = await storage.uploadChatAttachment(
        userId: user.id,
        bookingId: widget.bookingId,
        file: uploadFile,
      );
      await messageService.sendImage(
        bookingId: widget.bookingId,
        senderId: user.id,
        imageUrl: imageUrl,
      );
      ref.invalidate(conversationsInboxProvider(MessagingInboxRole.client));
      ref.invalidate(conversationsInboxProvider(MessagingInboxRole.prestataire));
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

    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    final appBarStart = theme.colorScheme.primary;
    final scaffoldBg = theme.colorScheme.surface;

    final userId = switch (ref.watch(authNotifierProvider)) {

      AsyncData(:final value) => value?.id,

      _ => null,

    };



    final headerAsync = ref.watch(chatInboxItemProvider(_inboxKey));

    final messagesAsync =

        ref.watch(messagesProvider(widget.bookingId));

    final headerForRole = headerAsync.asData?.value ?? _lastHeader;
    final isPresta = widget.viewerRole == MessagingInboxRole.prestataire ||
        (widget.viewerRole == null &&
            headerForRole != null &&
            !headerForRole.showSalonName);
    final quickTemplates = isPresta
        ? ChatMessageTemplates.prestataire
        : ChatMessageTemplates.client;

    ref.listen(messagesProvider(widget.bookingId), (prev, next) {

      unawaited(_markRead());

      final count = next.asData?.value.length;

      if (count != null) _onMessagesUpdated(count);

    });

    ref.listen(chatInboxItemProvider(_inboxKey), (_, next) {
      final fresh = next.asData?.value;
      if (fresh != null && mounted) {
        setState(() => _lastHeader = fresh);
      }
    });



    WidgetsBinding.instance.addPostFrameCallback((_) {

      unawaited(_markRead());

    });



    final freshHeader = headerAsync.asData?.value;
    if (freshHeader != null) {
      _lastHeader = freshHeader;
    }
    final header = freshHeader ?? _lastHeader;



    return Scaffold(

      backgroundColor: scaffoldBg,

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
        onDeleteChat: _confirmDeleteChat,
      ),

      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appBarStart.withValues(alpha: isDark ? 0.12 : 0.08),
              scaffoldBg,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Center(
                child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh
                      .withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
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
                      ref.invalidate(messagesProvider(widget.bookingId)),
                ),
              ),

              data: (messages) {

                return ChatMessageList(

                  messages: messages,

                  currentUserId: userId,

                  scrollController: _scrollController,

                  onDeleteMessage: userId == null ? null : _handleMessageLongPress,

                );

              },

              ),
            ),
            ChatComposer(
              controller: _controller,
              sending: _sending,
              attachingImage: _attachingImage,
              onSend: _send,
              onAttachImage: _sendImage,
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


