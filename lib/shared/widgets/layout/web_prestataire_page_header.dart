import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/notifications/widgets/in_app_notifications_sheet.dart';
import '../../../features/prestataire/providers/profile/current_prestataire_provider.dart';
import '../../../features/prestataire/providers/profile/prestataire_profile_form_provider.dart';
import '../../../features/profile/providers/current_user_profile_provider.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/notifications/in_app_notification_audience.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../layout/discovery_responsive.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_fonts.dart';
import '../app/app_avatar.dart';

/// En-tête page prestataire sur web (dashboard, agenda, clients, chat, profil).
class WebPrestatairePageHeader extends ConsumerWidget {
  const WebPrestatairePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.compact = false,
    this.onRefresh,
    this.showMessagesAction = true,
  });

  final String title;
  final String? subtitle;
  final bool compact;
  final Future<void> Function()? onRefresh;
  final bool showMessagesAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebSiteLayout) return const SizedBox.shrink();

    final theme = Theme.of(context);
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
    final avatarName = _resolveAvatarDisplayName(
      userProfile: userProfile,
      greetingName: greetingName,
      salon: salon,
    );

    final hPad = layout.webShellHorizontalPadding;
    final topPad = compact ? 16.0 : layout.webShellTopPadding;

    return Material(
      color: theme.colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          boxShadow: theme.brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: AppColors.brandBrown.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, compact ? 14 : 18),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackActions = constraints.maxWidth < 640;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.35,
                      height: 1.1,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: AppFonts.body,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              );

              final profileChip = _WebPrestaProfileChip(
                greetingName: greetingName,
                salon: salon,
                avatarUrl: avatarUrl,
                avatarName: avatarName,
                unreadNotif: unreadNotif,
                unreadMsg: unreadMsg,
                showMessagesAction: showMessagesAction,
                onRefresh: onRefresh,
                onNotifications: () => showInAppNotificationsSheet(
                  context,
                  ref,
                  audience: InAppNotificationAudience.prestataire,
                ),
                onMessages: () => context.goPrestataireMessages(),
              );

              if (stackActions) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titleBlock,
                    const SizedBox(height: 14),
                    profileChip,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 16),
                  profileChip,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WebPrestaProfileChip extends StatelessWidget {
  const _WebPrestaProfileChip({
    required this.greetingName,
    required this.salon,
    required this.avatarUrl,
    required this.avatarName,
    required this.unreadNotif,
    required this.unreadMsg,
    required this.showMessagesAction,
    required this.onNotifications,
    required this.onMessages,
    this.onRefresh,
  });

  final String greetingName;
  final String salon;
  final String? avatarUrl;
  final String avatarName;
  final int unreadNotif;
  final int unreadMsg;
  final bool showMessagesAction;
  final VoidCallback onNotifications;
  final VoidCallback onMessages;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = salon.isNotEmpty ? salon : DiscPrestaWorkspace.spaceLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(
              imageUrl: avatarUrl,
              displayName: avatarName,
              radius: 18,
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DiscPrestaWorkspace.greeting(greetingName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (onRefresh != null)
              _WebIconButton(
                icon: Icons.sync_rounded,
                tooltip: DiscPrestaWorkspace.refreshTooltip,
                onTap: () => onRefresh!(),
              ),
            _WebIconButton(
              icon: Icons.notifications_outlined,
              tooltip: DiscPrestaWorkspace.notificationsTooltip,
              badge: unreadNotif,
              onTap: onNotifications,
            ),
            if (showMessagesAction)
              _WebIconButton(
                icon: Icons.chat_bubble_outline_rounded,
                tooltip: DiscPrestaWorkspace.messagesTooltip,
                badge: unreadMsg,
                onTap: onMessages,
              ),
          ],
        ),
      ),
    );
  }
}

class _WebIconButton extends StatelessWidget {
  const _WebIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.14),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                if (badge > 0)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppColors.notificationDot,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
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
