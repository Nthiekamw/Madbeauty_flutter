import 'dart:async';



import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';



import '../../../core/constants/app_strings.dart';

import '../../../features/auth/providers/auth_notifier.dart';

import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../services/supabase/messaging/message_service.dart';
import '../providers/message_provider.dart';

import '../../../shared/widgets/app/app_snack_bar.dart';

import '../models/conversation_inbox_item.dart';

import '../logic/chat_message_moderator.dart';
import '../logic/chat_message_templates.dart';
import '../../prestataire/providers/current_prestataire_provider.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_message_list.dart';
import '../../trust/widgets/report_content_sheet.dart';
import '../../../services/supabase/trust/content_report_service.dart';
import '../widgets/chat_screen_app_bar.dart';



class ChatScreen extends ConsumerStatefulWidget {

  const ChatScreen({super.key, required this.bookingId});



  /// Identifiant de la réservation (booking).

  final String bookingId;



  @override

  ConsumerState<ChatScreen> createState() => _ChatScreenState();

}



class _ChatScreenState extends ConsumerState<ChatScreen> {

  final _controller = TextEditingController();

  final _scrollController = ScrollController();

  bool _sending = false;

  int _lastMessageCount = 0;
  ConversationInboxItem? _lastHeader;



  @override

  void dispose() {

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



  Future<void> _markRead() async {

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



  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final moderation = ChatMessageModerator.analyze(text);
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

    final user = switch (ref.read(authNotifierProvider)) {

      AsyncData(:final value) => value,

      _ => null,

    };

    if (service == null || user == null) return;



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

      parts.add(

        DateFormat('d MMM yyyy • HH:mm', 'fr_FR')

            .format(header.reservationDate!.toLocal()),

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



    final headerAsync = ref.watch(chatInboxItemProvider(widget.bookingId));

    final messagesAsync =

        ref.watch(messagesProvider(widget.bookingId));

    final isPresta =
        ref.watch(currentPrestataireProvider).asData?.value != null;
    final quickTemplates = isPresta
        ? ChatMessageTemplates.prestataire
        : ChatMessageTemplates.client;

    ref.listen(messagesProvider(widget.bookingId), (prev, next) {

      unawaited(_markRead());

      final count = next.asData?.value.length;

      if (count != null) _onMessagesUpdated(count);

    });

    ref.listen(chatInboxItemProvider(widget.bookingId), (_, next) {
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
        avatarUrl: header?.peerAvatarUrl,
        subtitle: _headerSubtitle(header),
        onReport: header == null
            ? null
            : () => showReportContentSheet(
                  context,
                  targetType: ContentReportTargetType.conversation,
                  targetId: header.conversation.id,
                ),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                DiscChat.moderationSafetyHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ),
            Expanded(
              child: messagesAsync.when(

              loading: () => const Center(child: CircularProgressIndicator()),

              error: (_, __) => Center(child: Text(DiscChat.loadError)),

              data: (messages) {

                return ChatMessageList(

                  messages: messages,

                  currentUserId: userId,

                  scrollController: _scrollController,

                );

              },

              ),
            ),
            ChatComposer(
              controller: _controller,
              sending: _sending,
              onSend: _send,
              quickReplyTemplates: quickTemplates,
            ),
          ],
        ),
      ),

    );

  }

}


