import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../models/conversation_inbox_item.dart';
import 'conversation_read_status_badge.dart';

class ConversationListTile extends StatelessWidget {
  const ConversationListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ConversationInboxItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hasUnread = item.hasUnread;
    final preview = item.lastMessagePreview?.trim();
    final subtitle = preview == null || preview.isEmpty
        ? _reservationSubtitle()
        : (item.isLastMessageMine ? '${DiscChat.you}: $preview' : preview);

    return Material(
      color: hasUnread
          ? primary.withValues(alpha: 0.04)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AppAvatar(
                    imageUrl: item.peerAvatarUrl,
                    displayName: item.peerDisplayName,
                    radius: 28,
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.peerDisplayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight:
                                  hasUnread ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (item.lastMessageAt != null)
                          Text(
                            _formatTime(item.lastMessageAt!.toLocal()),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: hasUnread
                                  ? primary
                                  : theme.colorScheme.outline,
                              fontWeight:
                                  hasUnread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasUnread
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            hasUnread ? FontWeight.w600 : FontWeight.w400,
                        height: 1.25,
                      ),
                    ),
                    if (item.hasConversationActivity) ...[
                      const SizedBox(height: 8),
                      ConversationReadStatusBadge(
                        unreadCount: item.unreadCount,
                        showReadWhenZero: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _reservationSubtitle() {
    final parts = <String>[];
    if (item.serviceName?.trim().isNotEmpty == true) {
      parts.add(item.serviceName!.trim());
    }
    if (item.reservationDate != null) {
      parts.add(
        DateFormat('d MMM • HH:mm', 'fr_FR').format(
          item.reservationDate!.toLocal(),
        ),
      );
    }
    if (parts.isEmpty) return DiscChat.reservationPrefix;
    return parts.join(' · ');
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    if (day == today) {
      return DateFormat('HH:mm', 'fr_FR').format(dt);
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return DiscChat.yesterday;
    }
    return DateFormat('d/MM', 'fr_FR').format(dt);
  }
}
