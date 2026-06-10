import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Pastille « Lu » / « Non lu » (+ nombre optionnel) sur une ligne inbox.
class ConversationReadStatusBadge extends StatelessWidget {
  const ConversationReadStatusBadge({
    super.key,
    required this.unreadCount,
    this.showReadWhenZero = true,
    this.isOutgoingPendingRead = false,
  });

  final int unreadCount;
  final bool showReadWhenZero;
  final bool isOutgoingPendingRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = unreadCount > 0;

    if (!hasUnread && !isOutgoingPendingRead && !showReadWhenZero) {
      return const SizedBox.shrink();
    }

    final Color bg;
    final Color fg;
    final String label;

    if (hasUnread) {
      bg = theme.colorScheme.primary.withValues(alpha: 0.14);
      fg = theme.colorScheme.primary;
      label = unreadCount > 1
          ? DiscChat.unreadCountLabel(unreadCount)
          : DiscChat.unreadLabel;
    } else if (isOutgoingPendingRead) {
      bg = theme.colorScheme.secondaryContainer.withValues(alpha: 0.65);
      fg = theme.colorScheme.onSecondaryContainer;
      label = DiscChat.sentLabel;
    } else {
      bg = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9);
      fg = theme.colorScheme.onSurfaceVariant;
      label = DiscChat.readLabel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasUnread
              ? theme.colorScheme.primary.withValues(alpha: 0.26)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: fg,
          fontSize: 11,
        ),
      ),
    );
  }
}

