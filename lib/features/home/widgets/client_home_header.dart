import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../services/notifications/in_app_notifications_sheet.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../../shared/widgets/app/app_avatar.dart';
import '../theme/home_styles.dart';
import '../../../shared/theme/app_colors.dart';

/// En-tête accueil client : carte compacte, avatar centré.
class ClientHomeHeader extends StatelessWidget {
  const ClientHomeHeader({
    super.key,
    required this.greetingLine,
    required this.subtitle,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.trailing,
    this.onAvatarTap,
    this.onNotificationsTap,
    this.notificationsUnreadCount = 0,
  });

  final String greetingLine;
  final String subtitle;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final Widget? trailing;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsTap;
  final int notificationsUnreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 360;
    final normalizedDisplayName = normalizeSingleLineText(displayName);
    final avatarRadius = isCompact ? 30.0 : 34.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: HomeStyles.heroBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
          colors: [
            primary.withValues(alpha: isDark ? 0.45 : 0.72),
            theme.colorScheme.primaryContainer.withValues(
              alpha: isDark ? 0.6 : 0.88,
            ),
            tertiary.withValues(alpha: isDark ? 0.25 : 0.35),
          ],
        ),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.3 : 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.14 : 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isCompact ? 12 : 16,
          12,
          isCompact ? 12 : 16,
          14,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Center(
                  child: trailing ??
                      _AvatarButton(
                        onTap: onAvatarTap,
                        child: AppAvatar(
                          imageUrl: avatarUrl,
                          radius: avatarRadius,
                          displayName: normalizedDisplayName.isEmpty
                              ? null
                              : normalizedDisplayName,
                          email: email.isEmpty ? null : email,
                        ),
                      ),
                ),
                const SizedBox(height: 10),
                _BrandBadge(primary: primary, theme: theme),
                const SizedBox(height: 8),
                Text(
                  greetingLine,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    height: 1.15,
                    fontSize: isCompact ? 18 : 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                    fontSize: isCompact ? 12 : null,
                  ),
                ),
              ],
            ),
            if (onNotificationsTap != null)
              Positioned(
                top: 0,
                right: 0,
                child: NotificationBellButton(
                  compact: isCompact,
                  unreadCount: notificationsUnreadCount,
                  onPressed: onNotificationsTap!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.primary, required this.theme});
  final Color primary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.brandLogoBackground.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.brandGold.withValues(alpha: 0.45),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGoldGlow12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Image.asset(
        AppAssets.logo,
        height: 22,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Text(
          'MadBeauty',
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
            color: AppColors.brandGoldLight,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ring = theme.colorScheme.primary.withValues(alpha: 0.35);

    final avatar = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return avatar;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }
}

