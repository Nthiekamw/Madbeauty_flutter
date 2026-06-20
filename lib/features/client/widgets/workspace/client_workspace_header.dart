import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/user/user_profile.dart';
import '../../../../services/notifications/in_app_notification_audience.dart';
import '../../../../services/notifications/in_app_notifications_provider.dart';
import '../../../notifications/widgets/in_app_notifications_sheet.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../auth/guest/guest_mode_provider.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../home/providers/home_profile_provider.dart';
import '../../../profile/providers/current_user_profile_provider.dart';

/// En-tête client (accueil, recherche, réservations, messages) — aligné prestataire.
class ClientWorkspaceHeader extends ConsumerWidget {
  const ClientWorkspaceHeader({
    super.key,
    this.subtitle = DiscClientWorkspace.searchSubtitle,
    this.compact = false,
  });

  final String subtitle;

  /// Variante réduite (écran Catalogue uniquement).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final responsive = DiscoveryResponsive.of(context);
    final horizontal = responsive.horizontalPadding;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final stackedLayout = screenWidth < 440;

    final userProfile = ref.watch(currentUserProfileProvider).asData?.value;
    final authUser = ref.watch(authNotifierProvider).asData?.value;
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final profileSnapshot = ref.watch(homeProfileSnapshotProvider).asData?.value;
    final unreadNotif = ref.watch(
      scopedUnreadInAppNotificationsCountProvider(
        InAppNotificationAudience.client,
      ),
    );

    final greetingName = _resolveGreetingName(
      isGuest: isGuest,
      userProfile: userProfile,
      authMetadataPrenom: authUser?.userMetadata?['prenom'] as String?,
      profileDisplayName: profileSnapshot?.displayName,
      authFullName: authUser?.userMetadata?['full_name'] as String?,
    );
    final avatarUrl = userProfile?.avatarUrl ??
        (authUser?.userMetadata?['avatar_url'] as String?);
    final avatarDisplayName = _resolveAvatarDisplayName(
      userProfile: userProfile,
      greetingName: greetingName,
      profileDisplayName: profileSnapshot?.displayName,
      email: authUser?.email,
    );
    final lineSubtitle = subtitle.trim().isNotEmpty
        ? subtitle.trim()
        : DiscClientWorkspace.searchSubtitle;

    final avatarRadius = compact
        ? (responsive.isCompact ? 20.0 : 22.0)
        : (responsive.isCompact ? 26.0 : 28.0);
    final iconButtonSize = compact ? 32.0 : 36.0;
    final iconSize = compact ? 15.0 : 17.0;

    final profileBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.92),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppAvatar(
            imageUrl: avatarUrl,
            displayName: avatarDisplayName,
            radius: avatarRadius,
          ),
        ),
        SizedBox(width: responsive.isCompact ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DiscClientWorkspace.greeting(greetingName),
                softWrap: true,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: onPrimary,
                  letterSpacing: -0.15,
                  height: 1.15,
                  fontSize: compact
                      ? (responsive.isCompact ? 13 : 14)
                      : (responsive.isCompact ? 16 : 17),
                ),
              ),
              if (lineSubtitle.isNotEmpty) ...[
                SizedBox(height: compact ? 2 : 4),
                Text(
                  lineSubtitle,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    color: onPrimary.withValues(alpha: 0.9),
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                    fontSize: compact
                        ? (responsive.isCompact ? 10.5 : 11)
                        : (responsive.isCompact ? 12.5 : 13.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final actions = _ClientHeaderActions(
      unreadNotif: unreadNotif,
      buttonSize: iconButtonSize,
      iconSize: iconSize,
      gap: responsive.isCompact ? 4 : 5,
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: compact
            ? (stackedLayout ? 96 : 80)
            : (stackedLayout ? 124 : 108),
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandBrown.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.brandBrown.withValues(alpha: 0.96),
                      AppColors.brandBrownMid.withValues(alpha: 0.94),
                      AppColors.brandBrown.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -30,
              child: Icon(
                Icons.spa_outlined,
                size: 160,
                color: onPrimary.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                compact
                    ? (stackedLayout ? 14 : 16)
                    : (stackedLayout ? 22 : 24),
                horizontal,
                compact
                    ? (stackedLayout ? 14 : 16)
                    : (stackedLayout ? 20 : 24),
              ),
              child: stackedLayout
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        profileBlock,
                        SizedBox(height: compact ? 10 : 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: actions,
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: profileBlock),
                        const SizedBox(width: 8),
                        actions,
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

String _resolveGreetingName({
  required bool isGuest,
  required UserProfile? userProfile,
  required String? authMetadataPrenom,
  required String? profileDisplayName,
  required String? authFullName,
}) {
  if (isGuest) return 'toi';

  final prenom = userProfile?.prenom?.trim() ?? '';
  if (prenom.isNotEmpty) return prenom;

  final metaPrenom = authMetadataPrenom?.trim() ?? '';
  if (metaPrenom.isNotEmpty) return metaPrenom;

  final nom = userProfile?.nom?.trim() ?? '';
  if (nom.isNotEmpty) return nom.split(RegExp(r'\s+')).first;

  final display = profileDisplayName?.trim() ?? '';
  if (display.isNotEmpty) return display.split(RegExp(r'\s+')).first;

  final full = authFullName?.trim() ?? '';
  if (full.isNotEmpty) return full.split(RegExp(r'\s+')).first;

  return 'toi';
}

String _resolveAvatarDisplayName({
  required UserProfile? userProfile,
  required String greetingName,
  required String? profileDisplayName,
  required String? email,
}) {
  final prenom = userProfile?.prenom?.trim() ?? '';
  final nom = userProfile?.nom?.trim() ?? '';
  if (prenom.isNotEmpty && nom.isNotEmpty) return '$prenom $nom';
  if (prenom.isNotEmpty) return prenom;
  if (nom.isNotEmpty) return nom;

  final display = profileDisplayName?.trim() ?? '';
  if (display.isNotEmpty) return display;

  if (greetingName.isNotEmpty && greetingName != 'toi') return greetingName;

  final mail = email?.trim() ?? '';
  if (mail.isNotEmpty) return mail;

  return CoreStrings.appName;
}

class _ClientHeaderActions extends ConsumerWidget {
  const _ClientHeaderActions({
    required this.unreadNotif,
    required this.buttonSize,
    required this.iconSize,
    required this.gap,
  });

  final int unreadNotif;
  final double buttonSize;
  final double iconSize;
  final double gap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIconButton(
          icon: Icons.notifications_outlined,
          tooltip: DiscClientWorkspace.notificationsTooltip,
          badge: unreadNotif,
          size: buttonSize,
          iconSize: iconSize,
          gap: 0,
          onTap: () => showInAppNotificationsSheet(
            context,
            ref,
            audience: InAppNotificationAudience.client,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.size,
    required this.iconSize,
    required this.gap,
    this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String tooltip;
  final double size;
  final double iconSize;
  final double gap;
  final VoidCallback? onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    const iconColor = AppColors.white;

    return Padding(
      padding: EdgeInsets.only(left: gap),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(11),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: iconSize, color: iconColor),
                  if (badge > 0)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandGoldLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.brandBrown.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.brandBrown,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
