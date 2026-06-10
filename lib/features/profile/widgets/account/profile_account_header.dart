import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/user/user_profile.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../../shared/utils/text_normalizer.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../stats/profile_stats_row.dart';
import '../../../../shared/theme/app_colors.dart';

/// En-tête profil : photo, nom, statistiques en bas de la carte.
class ProfileAccountHeader extends StatelessWidget {
  const ProfileAccountHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.profile,
    this.avatarBytes,
    this.onEditName,
    this.onEditPhoto,
    this.photoLoading = false,
    this.showAmbassadorBadge = false,
    this.showAdminBadge = false,
  });

  final String displayName;
  final String email;
  final UserProfile? profile;
  final Uint8List? avatarBytes;
  final VoidCallback? onEditName;
  final VoidCallback? onEditPhoto;
  final bool photoLoading;
  final bool showAmbassadorBadge;
  final bool showAdminBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;
    final normalizedDisplayName = normalizeSingleLineText(displayName);

    return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: DiscoveryStyles.heroBorderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.6, 1.0],
            colors: [
              primary.withValues(alpha: isDark ? 0.4 : 0.65),
              theme.colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.6 : 0.88,
              ),
              tertiary.withValues(alpha: isDark ? 0.2 : 0.3),
            ],
          ),
          border: Border.all(
            color: primary.withValues(alpha: isDark ? 0.3 : 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.15 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primary.withValues(alpha: 0.3),
                        width: 3,
                      ),
                    ),
                    child: _ProfileAvatar(
                      radius: 52,
                      imageUrl: profile?.avatarUrl,
                      displayName: normalizedDisplayName,
                      email: email,
                      avatarBytes: avatarBytes,
                    ),
                  ),
                  if (photoLoading)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.6,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                  if (!photoLoading && onEditPhoto != null)
                    Material(
                      color: primary,
                      shape: const CircleBorder(),
                      elevation: 2,
                      shadowColor: AppColors.scrimDark26,
                      child: InkWell(
                        onTap: onEditPhoto,
                        customBorder: const CircleBorder(),
                        child: const Padding(
                          padding: EdgeInsets.all(9),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                normalizedDisplayName.isEmpty ? displayName : normalizedDisplayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              if (showAdminBadge || showAmbassadorBadge) ...[
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (showAdminBadge) const _AdminRoleBadge(),
                    if (showAmbassadorBadge) const _AmbassadorRoleBadge(),
                  ],
                ),
              ],
              if (onEditName != null) ...[
                const SizedBox(height: 10),
                _EditChip(
                  icon: Icons.edit_rounded,
                  label: ShellStrings.profileEditName,
                  onTap: onEditName!,
                ),
              ],
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(
                    alpha: isDark ? 0.22 : 0.72,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const ProfileStatsRow(),
              ),
            ],
          ),
        ),
      );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.radius,
    required this.displayName,
    required this.email,
    this.imageUrl,
    this.avatarBytes,
  });

  final double radius;
  final String? imageUrl;
  final String displayName;
  final String email;
  final Uint8List? avatarBytes;

  @override
  Widget build(BuildContext context) {
    final bytes = avatarBytes;
    if (bytes != null && bytes.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(bytes),
      );
    }
    return AppAvatar(
      radius: radius,
      imageUrl: imageUrl,
      displayName: displayName,
      email: email.isNotEmpty ? email : null,
    );
  }
}

class _AdminRoleBadge extends StatelessWidget {
  const _AdminRoleBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.adminBg12,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.adminBorder30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield_rounded,
            size: 18,
            color: AppColors.adminAccentMid,
          ),
          const SizedBox(width: 6),
          Text(
            DiscProfile.adminBadgeLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.adminAccentDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbassadorRoleBadge extends StatelessWidget {
  const _AmbassadorRoleBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.purpleAccentBg15,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purpleAccentBorder35),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.military_tech_rounded,
            size: 18,
            color: AppColors.ambassador,
          ),
          const SizedBox(width: 6),
          Text(
            DiscProfile.ambassadorBadgeLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.ambassadorMid,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditChip extends StatelessWidget {
  const _EditChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primary.withValues(alpha: 0.22)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


