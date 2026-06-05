import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import 'chat_peer_header.dart';
import '../../../shared/theme/app_colors.dart';

/// Barre supérieure du chat (dégradé + interlocuteur).
class ChatScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatScreenAppBar({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.subtitle,
    this.onReport,
  });

  final String displayName;
  final String? avatarUrl;
  final String? subtitle;
  final VoidCallback? onReport;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
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
                    avatarUrl: avatarUrl,
                    subtitle: subtitle,
                    titleColor: AppColors.white,
                    subtitleColor: AppColors.onPrimaryMuted88,
                    onLightGradient: true,
                  ),
                ),
                if (onReport != null)
                  IconButton(
                    onPressed: onReport,
                    icon: const Icon(Icons.flag_outlined, size: 22),
                    color: AppColors.white,
                    tooltip: DiscReport.action,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

