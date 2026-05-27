import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Pastille « Lu » / « Non lu » (+ nombre optionnel) sur une ligne inbox.
class ConversationReadStatusBadge extends StatelessWidget {
  const ConversationReadStatusBadge({
    super.key,
    required this.unreadCount,
    this.showReadWhenZero = true,
  });

  final int unreadCount;
  final bool showReadWhenZero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = unreadCount > 0;

    if (!hasUnread && !showReadWhenZero) {
      return const SizedBox.shrink();
    }

    final Color bg;
    final Color fg;
    final String label;

    if (hasUnread) {
      bg = theme.colorScheme.primaryContainer;
      fg = theme.colorScheme.onPrimaryContainer;
      label = unreadCount > 1
          ? DiscChat.unreadCountLabel(unreadCount)
          : DiscChat.unreadLabel;
    } else {
      bg = theme.colorScheme.surfaceContainerHighest;
      fg = theme.colorScheme.onSurfaceVariant;
      label = DiscChat.readLabel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
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
