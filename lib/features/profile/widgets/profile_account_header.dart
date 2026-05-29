import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../../shared/widgets/app/app_avatar.dart';

/// En-tête profil : photo, nom, actions de modification.
class ProfileAccountHeader extends StatelessWidget {
  const ProfileAccountHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.profile,
    this.avatarBytes,
    this.onEditPhoto,
    this.onEditName,
    this.photoLoading = false,
  });

  final String displayName;
  final String email;
  final UserProfile? profile;
  final Uint8List? avatarBytes;
  final VoidCallback? onEditPhoto;
  final VoidCallback? onEditName;
  final bool photoLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final normalizedDisplayName = normalizeSingleLineText(displayName);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
      child: DecoratedBox(
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                    child: _AvatarPreview(
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
                  if (onEditPhoto != null && !photoLoading)
                    Material(
                      color: primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onEditPhoto,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: theme.colorScheme.onPrimary,
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
              if (onEditName != null || onEditPhoto != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (onEditName != null)
                      _EditChip(
                        icon: Icons.edit_rounded,
                        label: ShellStrings.profileEditName,
                        onTap: onEditName!,
                      ),
                    if (onEditPhoto != null)
                      _EditChip(
                        icon: Icons.photo_camera_outlined,
                        label: ShellStrings.profileEditPhoto,
                        onTap: onEditPhoto!,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
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

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
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
