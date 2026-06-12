import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/text_normalizer.dart';
import '../../../../shared/utils/user_presence_formatter.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../models/conversation_inbox_item.dart';
import 'conversation_read_status_badge.dart';
import '../../../../shared/theme/app_colors.dart';

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
    final isPeerOnline = UserPresenceFormatter.isOnline(item.peerLastSeenAt);
    final presenceLabel = UserPresenceFormatter.label(item.peerLastSeenAt);
    final peerName = normalizeSingleLineText(
      item.showSalonName
          ? item.peerDisplayName
          : (item.peerPrenom?.trim().isNotEmpty == true &&
                  item.peerNom?.trim().isNotEmpty == true
              ? '${item.peerPrenom!.trim()} ${item.peerNom!.trim()}'
              : item.peerDisplayName),
    );
    final hasSplitPeerName = !item.showSalonName &&
        item.peerPrenom?.trim().isNotEmpty == true &&
        item.peerNom?.trim().isNotEmpty == true;
    final preview = item.lastMessagePreview?.trim();
    final subtitle = preview == null || preview.isEmpty
        ? _reservationSubtitle()
        : (item.isLastMessageMine ? '${DiscChat.you}: $preview' : preview);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: hasUnread
            ? primary.withValues(alpha: 0.06)
            : theme.colorScheme.surface,
        border: Border.all(
          color: hasUnread
              ? primary.withValues(alpha: 0.22)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: hasUnread
                ? primary.withValues(alpha: 0.08)
                : AppColors.scrimLight05,
            blurRadius: hasUnread ? 14 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AvatarWithStatus(
                  imageUrl: item.peerAvatarUrl,
                  displayName:
                      peerName.isEmpty ? item.peerDisplayName : peerName,
                  hasUnread: hasUnread,
                  unreadCount: item.unreadCount,
                  isOnline: isPeerOnline,
                  primary: primary,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: hasSplitPeerName
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.peerPrenom!.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontFamily: AppFonts.display,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      Text(
                                        item.peerNom!.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                          fontFamily: AppFonts.display,
                                          fontWeight: FontWeight.w600,
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    peerName.isEmpty
                                        ? item.peerDisplayName
                                        : peerName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontFamily: AppFonts.display,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      height: 1.15,
                                    ),
                                  ),
                          ),
                          if (item.lastMessageAt != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(item.lastMessageAt!.toLocal()),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: hasUnread
                                    ? primary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        presenceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: AppFonts.body,
                          fontWeight:
                              isPeerOnline ? FontWeight.w700 : FontWeight.w500,
                          color: isPeerOnline
                              ? const Color(0xFF16A34A)
                              : theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.85),
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                          height: 1.3,
                          fontSize: 14,
                        ),
                      ),
                      if (item.hasConversationActivity) ...[
                        const SizedBox(height: 8),
                        ConversationReadStatusBadge(
                          unreadCount: item.unreadCount,
                          showReadWhenZero: !item.isOutgoingUnread,
                          isOutgoingPendingRead: item.isOutgoingUnread,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.45),
                ),
              ],
            ),
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

class _AvatarWithStatus extends StatelessWidget {
  const _AvatarWithStatus({
    required this.imageUrl,
    required this.displayName,
    required this.hasUnread,
    required this.unreadCount,
    required this.isOnline,
    required this.primary,
  });

  final String? imageUrl;
  final String displayName;
  final bool hasUnread;
  final int unreadCount;
  final bool isOnline;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withValues(alpha: hasUnread ? 0.55 : 0.28),
                primary.withValues(alpha: hasUnread ? 0.25 : 0.1),
              ],
            ),
          ),
          child: AppAvatar(
            imageUrl: imageUrl,
            displayName: displayName,
            radius: 27,
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        if (hasUnread && unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
