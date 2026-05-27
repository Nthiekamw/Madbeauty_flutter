import 'dart:async';



import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';



import '../../../core/constants/app_strings.dart';

import '../../../features/auth/providers/auth_notifier.dart';

import '../../../services/supabase/messaging/messaging_providers.dart';
import '../providers/message_provider.dart';

import '../../../shared/widgets/app_snack_bar.dart';

import '../models/conversation_inbox_item.dart';

import '../widgets/chat_composer.dart';

import '../widgets/chat_message_list.dart';

import '../widgets/chat_peer_header.dart';



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



    final service = ref.read(messageServiceProvider);

    final user = switch (ref.read(authNotifierProvider)) {

      AsyncData(:final value) => value,

      _ => null,

    };

    if (service == null || user == null) return;



    setState(() => _sending = true);

    _controller.clear();



    try {

      await service.send(

        bookingId: widget.bookingId,

        senderId: user.id,

        content: text,

      );

      ref.invalidate(conversationsInboxProvider(MessagingInboxRole.client));

      ref.invalidate(conversationsInboxProvider(MessagingInboxRole.prestataire));

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

    final userId = switch (ref.watch(authNotifierProvider)) {

      AsyncData(:final value) => value?.id,

      _ => null,

    };



    final headerAsync = ref.watch(chatInboxItemProvider(widget.bookingId));

    final messagesAsync =

        ref.watch(messagesProvider(widget.bookingId));



    ref.listen(messagesProvider(widget.bookingId), (prev, next) {

      unawaited(_markRead());

      final count = next.asData?.value.length;

      if (count != null) _onMessagesUpdated(count);

    });



    WidgetsBinding.instance.addPostFrameCallback((_) {

      unawaited(_markRead());

    });



    final header = headerAsync.asData?.value;



    return Scaffold(

      backgroundColor: isDark

          ? theme.colorScheme.surface

          : const Color(0xFFF2F2F7),

      appBar: AppBar(

        titleSpacing: 0,

        title: ChatPeerHeader(

          displayName: header?.peerDisplayName ?? DiscChat.inboxTitle,

          avatarUrl: header?.peerAvatarUrl,

          subtitle: _headerSubtitle(header),

        ),

      ),

      body: Column(

        children: [

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

          ),

        ],

      ),

    );

  }

}

