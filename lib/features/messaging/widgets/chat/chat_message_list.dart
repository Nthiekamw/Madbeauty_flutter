import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/messaging/message.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../logic/chat_message_moderator.dart';
import '../../logic/chat_message_receipt.dart';
import 'chat_bubble.dart';
import 'chat_content_width.dart';

/// Liste des messages avec séparateurs de date et regroupement par expéditeur.
class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    this.emptyPlaceholder,
    this.onDeleteMessage,
  });

  final List<Message> messages;
  final String? currentUserId;
  final ScrollController scrollController;
  final Widget? emptyPlaceholder;
  final void Function(Message message)? onDeleteMessage;

  static const _groupWindow = Duration(minutes: 5);

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return emptyPlaceholder ?? const _ChatEmptyBody();
    }

    return ChatContentWidth(
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isMine = msg.senderId == currentUserId;
          final showDate = index == 0 ||
              !_sameDay(messages[index - 1].createdAt, msg.createdAt);
          final isFirstInGroup = _isFirstInGroup(messages, index, currentUserId);
          final isLastInGroup = _isLastInGroup(messages, index, currentUserId);
          final canDelete = isMine && onDeleteMessage != null;

          return Column(
            children: [
              if (showDate) _DateSeparator(label: _dateLabel(msg.createdAt.toLocal())),
              GestureDetector(
                onLongPress: canDelete ? () => onDeleteMessage!(msg) : null,
                child: ChatBubble(
                  text: ChatMessageModerator.sanitizeForDisplay(msg.content),
                  isMine: isMine,
                  imageUrl: msg.imageUrl,
                  resultLabel: msg.kind == 'result_media'
                      ? msg.resultLabel
                      : null,
                  receiptStatus: isMine
                      ? chatOutgoingReceiptStatus(
                          isRead: msg.isRead,
                          deliveredAt: msg.deliveredAt,
                        )
                      : null,
                  isFirstInGroup: isFirstInGroup,
                  isLastInGroup: isLastInGroup,
                  timeLabel: DateFormat('HH:mm', 'fr_FR')
                      .format(msg.createdAt.toLocal()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isFirstInGroup(List<Message> list, int index, String? userId) {
    if (index == 0) return true;
    final current = list[index];
    final prev = list[index - 1];
    if (prev.senderId != current.senderId) return true;
    if (!_sameDay(prev.createdAt, current.createdAt)) return true;
    return current.createdAt.difference(prev.createdAt) > _groupWindow;
  }

  bool _isLastInGroup(List<Message> list, int index, String? userId) {
    if (index == list.length - 1) return true;
    final current = list[index];
    final next = list[index + 1];
    if (next.senderId != current.senderId) return true;
    if (!_sameDay(current.createdAt, next.createdAt)) return true;
    return next.createdAt.difference(current.createdAt) > _groupWindow;
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

class _ChatEmptyBody extends StatelessWidget {
  const _ChatEmptyBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight;
        final tight = maxHeight < 140;
        final padding = tight ? 12.0 : 32.0;
        final iconSize = tight ? 28.0 : 48.0;
        final gap = tight ? 6.0 : 14.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: maxHeight.isFinite
                  ? (maxHeight - padding * 2).clamp(0, double.infinity)
                  : 0,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: iconSize,
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                  ),
                  SizedBox(height: gap),
                  Text(
                    DiscChat.emptyBody,
                    textAlign: TextAlign.center,
                    maxLines: tight ? 2 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                      fontSize: tight ? 13 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
