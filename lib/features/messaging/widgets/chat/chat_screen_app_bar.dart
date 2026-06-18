import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import 'chat_peer_header.dart';
import '../../../../shared/theme/app_colors.dart';

/// Barre supérieure du chat (dégradé + interlocuteur).
class ChatScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatScreenAppBar({
    super.key,
    required this.displayName,
    this.peerPrenom,
    this.peerNom,
    this.avatarUrl,
    this.subtitle,
    this.peerLastSeenAt,
    this.useSalonName = false,
    this.onReport,
    this.onDeleteChat,
  });

  final String displayName;
  final String? peerPrenom;
  final String? peerNom;
  final String? avatarUrl;
  final String? subtitle;
  final DateTime? peerLastSeenAt;
  final bool useSalonName;
  final VoidCallback? onReport;
  final VoidCallback? onDeleteChat;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight,
      automaticallyImplyLeading: false,
      foregroundColor: AppColors.white,
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.transparent,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, Color.lerp(primary, secondary, 0.45)!],
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: AppColors.white,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                ),
                Expanded(
                  child: ChatPeerHeader(
                    displayName: displayName,
                    peerPrenom: peerPrenom,
                    peerNom: peerNom,
                    avatarUrl: avatarUrl,
                    subtitle: subtitle,
                    peerLastSeenAt: peerLastSeenAt,
                    useSalonName: useSalonName,
                    compact: true,
                    titleColor: AppColors.white,
                    subtitleColor: AppColors.onPrimaryMuted88,
                    onLightGradient: true,
                  ),
                ),
                if (onReport != null || onDeleteChat != null)
                  PopupMenuButton<_ChatMenuAction>(
                    icon: const Icon(Icons.more_vert_rounded, size: 22),
                    color: AppColors.white,
                    iconColor: AppColors.white,
                    tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                    onSelected: (action) {
                      switch (action) {
                        case _ChatMenuAction.report:
                          onReport?.call();
                        case _ChatMenuAction.deleteChat:
                          onDeleteChat?.call();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onDeleteChat != null)
                        const PopupMenuItem(
                          value: _ChatMenuAction.deleteChat,
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 20),
                              SizedBox(width: 10),
                              Text(DiscChat.deleteChatAction),
                            ],
                          ),
                        ),
                      if (onReport != null)
                        const PopupMenuItem(
                          value: _ChatMenuAction.report,
                          child: Row(
                            children: [
                              Icon(Icons.flag_outlined, size: 20),
                              SizedBox(width: 10),
                              Text(DiscReport.action),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _ChatMenuAction { deleteChat, report }

