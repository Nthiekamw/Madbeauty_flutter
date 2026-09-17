import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/user/user_profile.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/app_icons.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../../shared/utils/text_normalizer.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../stats/profile_stats_row.dart';

/// En-tête profil : photo, nom, statistiques.
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
    final normalizedDisplayName = normalizeSingleLineText(displayName);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DiscoveryStyles.heroBorderRadius,
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.22 : 0.14),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sideBySide = constraints.maxWidth >= 420;
            final identity = _ProfileIdentityBlock(
              radius: sideBySide ? 44 : 40,
              profile: profile,
              displayName: displayName,
              normalizedDisplayName: normalizedDisplayName,
              email: email,
              avatarBytes: avatarBytes,
              photoLoading: photoLoading,
              onEditPhoto: onEditPhoto,
              onEditName: onEditName,
              showAdminBadge: showAdminBadge,
              showAmbassadorBadge: showAmbassadorBadge,
              alignStart: sideBySide,
            );
            final stats = DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(
                  alpha: isDark ? 0.22 : 0.72,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: ProfileStatsRow(compact: true),
              ),
            );

            if (!sideBySide) {
              return Column(
                children: [
                  identity,
                  const SizedBox(height: 10),
                  stats,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(width: 18),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: stats,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileIdentityBlock extends StatelessWidget {
  const _ProfileIdentityBlock({
    required this.radius,
    required this.displayName,
    required this.normalizedDisplayName,
    required this.email,
    required this.photoLoading,
    required this.showAdminBadge,
    required this.showAmbassadorBadge,
    required this.alignStart,
    this.profile,
    this.avatarBytes,
    this.onEditPhoto,
    this.onEditName,
  });

  final double radius;
  final String displayName;
  final String normalizedDisplayName;
  final String email;
  final UserProfile? profile;
  final Uint8List? avatarBytes;
  final bool photoLoading;
  final VoidCallback? onEditPhoto;
  final VoidCallback? onEditName;
  final bool showAdminBadge;
  final bool showAmbassadorBadge;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final cross = alignStart
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: cross,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primary.withValues(alpha: 0.28),
                  width: 2,
                ),
              ),
              child: _ProfileAvatar(
                radius: radius,
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
                    color: theme.colorScheme.surface.withValues(alpha: 0.6),
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
                child: InkWell(
                  onTap: onEditPhoto,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(7),
                    child: Icon(
                      AppIcons.photo,
                      size: 16,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          normalizedDisplayName.isEmpty ? displayName : normalizedDisplayName,
          textAlign: alignStart ? TextAlign.start : TextAlign.center,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.2,
          ),
        ),
        if (showAdminBadge || showAmbassadorBadge) ...[
          const SizedBox(height: 8),
          Wrap(
            alignment: alignStart ? WrapAlignment.start : WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (showAdminBadge) const _AdminRoleBadge(),
              if (showAmbassadorBadge) const _AmbassadorRoleBadge(),
            ],
          ),
        ],
        if (onEditName != null) ...[
          const SizedBox(height: 8),
          _EditChip(
            icon: AppIcons.edit,
            label: ShellStrings.profileEditName,
            onTap: onEditName!,
          ),
        ],
      ],
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.adminBorder30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            AppIcons.shield,
            size: 16,
            color: AppColors.adminAccentMid,
          ),
          const SizedBox(width: 6),
          Text(
            DiscProfile.adminBadgeLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.purpleAccentBorder35),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            size: 16,
            color: AppColors.ambassador,
          ),
          const SizedBox(width: 6),
          Text(
            DiscProfile.ambassadorBadgeLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
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
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: primary.withValues(alpha: 0.22)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
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
