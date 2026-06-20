import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/models/domain/user/user_profile.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../services/notifications/in_app_notification_audience.dart';
import '../../../../../services/notifications/in_app_notifications_provider.dart';
import '../../../../notifications/widgets/in_app_notifications_sheet.dart';
import '../../../../../services/supabase/messaging/messaging_providers.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/app/app_avatar.dart';
import '../../../providers/profile/current_prestataire_provider.dart';
import '../../../providers/profile/prestataire_profile_form_provider.dart';
import '../../../../profile/providers/current_user_profile_provider.dart';
import '../../../../auth/providers/auth_notifier.dart';

/// En-tête marque (salon, actions) — dashboard, agenda, clients, profil, chat.
class PrestataireWorkspaceHeader extends ConsumerWidget {
  const PrestataireWorkspaceHeader({
    super.key,
    this.onRefresh,
    this.subtitle,
    this.showMessagesAction = true,
  });

  final Future<void> Function()? onRefresh;
  final String? subtitle;
  final bool showMessagesAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final responsive = DiscoveryResponsive.of(context);
    final horizontal = responsive.horizontalPadding;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final stackedLayout = screenWidth < 440;
    final profile = ref.watch(prestataireProfileFormProvider).asData?.value;
    final presta = ref.watch(currentPrestataireProvider).asData?.value;
    final userProfile = ref.watch(currentUserProfileProvider).asData?.value;
    final authUser = ref.watch(authNotifierProvider).asData?.value;
    final unreadNotif = ref.watch(
      scopedUnreadInAppNotificationsCountProvider(
        InAppNotificationAudience.prestataire,
      ),
    );
    final unreadMsg = ref
            .watch(messagingUnreadCountProvider(MessagingInboxRole.prestataire))
            .value ??
        0;

    final salon = profile?.nomSalon.trim() ?? presta?.nomSalon?.trim() ?? '';
    final greetingName = _resolveGreetingName(
      userProfile: userProfile,
      authMetadataPrenom: authUser?.userMetadata?['prenom'] as String?,
      nomAffiche: profile?.nomAffiche,
    );
    final avatarUrl = profile?.avatarUrl ?? userProfile?.avatarUrl;
    final avatarDisplayName = _resolveAvatarDisplayName(
      userProfile: userProfile,
      greetingName: greetingName,
      salon: salon,
    );
    final lineSubtitle = subtitle?.trim().isNotEmpty == true
        ? subtitle!.trim()
        : DiscPrestaWorkspace.spaceLabel;

    final avatarRadius = responsive.isCompact ? 26.0 : 28.0;
    const iconButtonSize = 36.0;
    const iconSize = 17.0;

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
                DiscPrestaWorkspace.greeting(greetingName),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: onPrimary,
                  letterSpacing: -0.15,
                  height: 1.15,
                  fontSize: responsive.isCompact ? 16 : 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                lineSubtitle,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  color: onPrimary.withValues(alpha: 0.9),
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                  fontSize: responsive.isCompact ? 12.5 : 13.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.fade,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );

    final actions = _HeaderActions(
      onRefresh: onRefresh,
      showMessagesAction: showMessagesAction,
      unreadNotif: unreadNotif,
      unreadMsg: unreadMsg,
      buttonSize: iconButtonSize,
      iconSize: iconSize,
      gap: responsive.isCompact ? 8 : 10,
      messagesGap: responsive.isCompact ? 14 : 16,
    );

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: stackedLayout ? 124 : 108,
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
                stackedLayout ? 22 : 24,
                horizontal,
                stackedLayout ? 20 : 24,
              ),
              child: stackedLayout
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        profileBlock,
                        const SizedBox(height: 14),
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
  required UserProfile? userProfile,
  required String? authMetadataPrenom,
  required String? nomAffiche,
}) {
  final prenom = userProfile?.prenom?.trim() ?? '';
  if (prenom.isNotEmpty) return prenom;

  final metaPrenom = authMetadataPrenom?.trim() ?? '';
  if (metaPrenom.isNotEmpty) return metaPrenom;

  final nom = userProfile?.nom?.trim() ?? '';
  if (nom.isNotEmpty) return nom.split(RegExp(r'\s+')).first;

  final affiche = nomAffiche?.trim() ?? '';
  if (affiche.isNotEmpty) return affiche.split(RegExp(r'\s+')).first;

  return DiscPrestaProfile.title;
}

String _resolveAvatarDisplayName({
  required UserProfile? userProfile,
  required String greetingName,
  required String salon,
}) {
  final prenom = userProfile?.prenom?.trim() ?? '';
  final nom = userProfile?.nom?.trim() ?? '';
  if (prenom.isNotEmpty && nom.isNotEmpty) return '$prenom $nom';
  if (prenom.isNotEmpty) return prenom;
  if (nom.isNotEmpty) return nom;
  if (greetingName.isNotEmpty && greetingName != DiscPrestaProfile.title) {
    return greetingName;
  }
  if (salon.isNotEmpty) return salon;
  return DiscPrestaProfile.title;
}

class _HeaderActions extends ConsumerWidget {
  const _HeaderActions({
    required this.onRefresh,
    required this.showMessagesAction,
    required this.unreadNotif,
    required this.unreadMsg,
    required this.buttonSize,
    required this.iconSize,
    required this.gap,
    required this.messagesGap,
  });

  final Future<void> Function()? onRefresh;
  final bool showMessagesAction;
  final int unreadNotif;
  final int unreadMsg;
  final double buttonSize;
  final double iconSize;
  final double gap;
  final double messagesGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRefresh != null)
          _HeaderIconButton(
            icon: Icons.sync_rounded,
            tooltip: DiscPrestaWorkspace.refreshTooltip,
            size: buttonSize,
            iconSize: iconSize,
            gap: gap,
            onTap: () => onRefresh!(),
          ),
        _HeaderIconButton(
          icon: Icons.credit_card_outlined,
          tooltip: DiscPrestaWorkspace.paymentsTooltip,
          size: buttonSize,
          iconSize: iconSize,
          gap: gap,
          onTap: () => context.pushPrestataireSubscription(),
        ),
        _HeaderIconButton(
          icon: Icons.notifications_outlined,
          tooltip: DiscPrestaWorkspace.notificationsTooltip,
          badge: unreadNotif,
          size: buttonSize,
          iconSize: iconSize,
          gap: gap,
          onTap: () => showInAppNotificationsSheet(
            context,
            ref,
            audience: InAppNotificationAudience.prestataire,
          ),
        ),
        if (showMessagesAction)
          _HeaderIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            tooltip: DiscPrestaWorkspace.messagesTooltip,
            badge: unreadMsg,
            size: buttonSize,
            iconSize: iconSize,
            gap: messagesGap,
            onTap: () => context.goPrestataireMessages(),
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
