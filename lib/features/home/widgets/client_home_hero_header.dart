import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/notifications/in_app_notifications_sheet.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_avatar.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../profile/providers/current_user_profile_provider.dart';
import '../providers/home_profile_provider.dart';

/// En-tête accueil client : avatar centré, notifications en haut à droite, salutation.
class ClientHomeHeroHeader extends ConsumerWidget {
  const ClientHomeHeroHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final userProfile = ref.watch(currentUserProfileProvider).asData?.value;
    final authUser = ref.watch(authNotifierProvider).asData?.value;
    final profileSnapshot = ref.watch(homeProfileSnapshotProvider).asData?.value;
    final unreadNotif = ref.watch(unreadInAppNotificationsCountProvider);

    final greetingName = _greetingName(
      isGuest: isGuest,
      userProfile: userProfile,
      authMetadataPrenom: authUser?.userMetadata?['prenom'] as String?,
      profileDisplayName: profileSnapshot?.displayName,
      authFullName: authUser?.userMetadata?['full_name'] as String?,
    );
    final avatarUrl = userProfile?.avatarUrl ??
        (authUser?.userMetadata?['avatar_url'] as String?);
    final avatarDisplayName = _avatarDisplayName(
      userProfile: userProfile,
      greetingName: greetingName,
      profileDisplayName: profileSnapshot?.displayName,
      email: authUser?.email,
    );
    final greetingLine = DiscHome.clientHomeGreeting(greetingName);
    final avatarRadius = MediaQuery.sizeOf(context).width < 360 ? 36.0 : 40.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brandBrown.withValues(alpha: 0.12),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandBrown.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AppAvatar(
                  imageUrl: avatarUrl,
                  displayName: avatarDisplayName,
                  radius: avatarRadius,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                greetingLine,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  height: 1.25,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: NotificationBellButton(
              compact: true,
              unreadCount: unreadNotif,
              onPressed: () => showInAppNotificationsSheet(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

String _greetingName({
  required bool isGuest,
  required UserProfile? userProfile,
  required String? authMetadataPrenom,
  required String? profileDisplayName,
  required String? authFullName,
}) {
  if (isGuest) return '';

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

  return '';
}

String _avatarDisplayName({
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

  if (greetingName.isNotEmpty) return greetingName;

  final mail = email?.trim() ?? '';
  if (mail.isNotEmpty) return mail;

  return CoreStrings.appName;
}
