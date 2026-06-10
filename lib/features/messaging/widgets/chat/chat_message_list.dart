import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/messaging/message.dart';
import '../../logic/chat_message_moderator.dart';
import 'chat_bubble.dart';

/// Liste des messages avec séparateurs de date.
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    this.emptyPlaceholder,
  });

  final List<Message> messages;
  final String? currentUserId;
  final ScrollController scrollController;
  final Widget? emptyPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return emptyPlaceholder ??
          Center(
            child: Text(
              DiscChat.emptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isMine = msg.senderId == currentUserId;
        final showDate = index == 0 ||
            !_sameDay(messages[index - 1].createdAt, msg.createdAt);

        return Column(
          children: [
            if (showDate)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _dateLabel(msg.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ChatBubble(
              text: ChatMessageModerator.sanitizeForDisplay(msg.content),
              isMine: isMine,
              imageUrl: msg.imageUrl,
              isReadByPeer: !isMine || msg.isRead,
              timeLabel:
                  DateFormat('HH:mm', 'fr_FR').format(msg.createdAt.toLocal()),
            ),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    if (day == today) return DiscChat.today;
    if (day == today.subtract(const Duration(days: 1))) {
      return DiscChat.yesterday;
    }
    return DateFormat('EEEE d MMMM', 'fr_FR').format(dt);
  }
}

