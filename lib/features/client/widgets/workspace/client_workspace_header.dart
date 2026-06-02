import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/notifications/in_app_notifications_provider.dart';
import '../../../../services/notifications/in_app_notifications_sheet.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../auth/guest/guest_mode_provider.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../home/providers/home_profile_provider.dart';

/// En-tête horizontal (avatar, bonjour, cloche) — accueil, recherche, chat.
class ClientWorkspaceHeader extends ConsumerWidget {
  const ClientWorkspaceHeader({
    super.key,
    this.subtitle = DiscClientWorkspace.searchSubtitle,
    this.onAvatarTap,
    this.onNotificationsTap,
  });

  final String subtitle;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authNotifierProvider);
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final profileAsync = ref.watch(homeProfileSnapshotProvider);
    final unread = ref.watch(unreadInAppNotificationsCountProvider);

    final user = auth.asData?.value;
    final displayName = switch (profileAsync) {
      AsyncData(:final value) when value != null => value.displayName,
      _ => (user?.userMetadata?['full_name'] as String?) ?? '',
    };
    final email = switch (profileAsync) {
      AsyncData(:final value) when value != null && value.email.isNotEmpty =>
        value.email,
      _ => user?.email ?? '',
    };
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    void defaultAvatarTap() {
      if (isGuest || user == null) {
        context.goLogin();
      } else {
        context.goClientProfile();
      }
    }

    void defaultNotifTap() {
      showInAppNotificationsSheet(context, ref);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAvatarTap ?? defaultAvatarTap,
              customBorder: const CircleBorder(),
              child: AppAvatar(
                imageUrl: avatarUrl,
                displayName: displayName,
                email: email,
                radius: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscClientWorkspace.greeting(displayName),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          NotificationBellButton(
            compact: true,
            unreadCount: unread,
            tooltip: DiscHome.notificationsTooltip,
            onPressed: onNotificationsTap ?? defaultNotifTap,
          ),
        ],
      ),
    );
  }
}
