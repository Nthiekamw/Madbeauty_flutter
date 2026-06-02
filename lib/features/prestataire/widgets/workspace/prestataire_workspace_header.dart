import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/notifications/in_app_notifications_provider.dart';
import '../../../../services/notifications/in_app_notifications_sheet.dart';
import '../../../../services/supabase/messaging/messaging_providers.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../logic/prestataire_profile_completeness.dart';
import '../../providers/current_prestataire_provider.dart';
import '../../providers/prestataire_profile_form_provider.dart';

/// En-tête sombre (salon + actions rapides) — agenda, clients, profil.
class PrestataireWorkspaceHeader extends ConsumerWidget {
  const PrestataireWorkspaceHeader({
    super.key,
    this.onRefresh,
  });

  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final profile = ref.watch(prestataireProfileFormProvider).asData?.value;
    final presta = ref.watch(currentPrestataireProvider).asData?.value;
    final unreadNotif = ref.watch(unreadInAppNotificationsCountProvider);
    final unreadMsg = ref
            .watch(messagingUnreadCountProvider(MessagingInboxRole.prestataire))
            .value ??
        0;

    final salon = profile?.nomSalon.trim() ?? presta?.nomSalon?.trim() ?? '';
    final displayName = salon.isNotEmpty
        ? salon.split(RegExp(r'\s+')).first
        : DiscPrestaProfile.title;
    final avatarUrl = profile?.avatarUrl;
    final complete = profile?.isProfessionallyComplete == true;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(28)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary,
                    Color.lerp(primary, Colors.black, 0.12)!,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -24,
            top: -12,
            child: Icon(
              Icons.spa_outlined,
              size: 120,
              color: onPrimary.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppAvatar(
                      imageUrl: avatarUrl,
                      displayName: salon.isNotEmpty ? salon : displayName,
                      radius: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DiscPrestaWorkspace.greeting(displayName),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w800,
                              color: onPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                DiscPrestaWorkspace.spaceLabel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: onPrimary.withValues(alpha: 0.85),
                                ),
                              ),
                              if (complete) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: onPrimary.withValues(alpha: 0.9),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(
                      icon: Icons.refresh_rounded,
                      tooltip: DiscPrestaWorkspace.refreshTooltip,
                      onPrimary: onPrimary,
                      onTap: onRefresh == null
                          ? null
                          : () => onRefresh!(),
                    ),
                    _HeaderIconButton(
                      icon: Icons.account_balance_wallet_outlined,
                      tooltip: DiscPrestaWorkspace.paymentsTooltip,
                      onPrimary: onPrimary,
                      onTap: () => context.pushPrestataireSubscription(),
                    ),
                    _HeaderIconButton(
                      icon: Icons.notifications_outlined,
                      tooltip: DiscPrestaWorkspace.notificationsTooltip,
                      onPrimary: onPrimary,
                      badge: unreadNotif,
                      onTap: () => showInAppNotificationsSheet(context, ref),
                    ),
                    _HeaderIconButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      tooltip: DiscPrestaWorkspace.messagesTooltip,
                      onPrimary: onPrimary,
                      badge: unreadMsg,
                      onTap: () => context.goPrestataireMessages(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPrimary,
    this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String tooltip;
  final Color onPrimary;
  final VoidCallback? onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Material(
        color: onPrimary.withValues(alpha: 0.12),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 20, color: onPrimary),
                  if (badge > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: themeError(context),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(minWidth: 14),
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
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

  Color themeError(BuildContext context) =>
      Theme.of(context).colorScheme.error;
}
