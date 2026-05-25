import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/app_avatar.dart';

/// En-tête profil : carte hero, photo, nom, e-mail, rôle.
class ProfileAccountHeader extends StatelessWidget {
  const ProfileAccountHeader({
    super.key,
    required this.displayName,
    required this.email,
    required this.rolesLabel,
    this.profile,
    this.avatarBytes,
    this.onEditPhoto,
    this.onEditName,
    this.photoLoading = false,
  });

  final UserProfile? profile;
  final String displayName;
  final String email;
  final String rolesLabel;
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
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
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _AvatarPreview(
                      radius: 52,
                      imageUrl: profile?.avatarUrl,
                      displayName: displayName,
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
                      elevation: 4,
                      shadowColor: primary.withValues(alpha: 0.4),
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
              const SizedBox(height: 16),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              if (onEditName != null) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: onEditName,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: primary.withValues(alpha: 0.25),
                      ),
                    ),
                    backgroundColor: primary.withValues(alpha: 0.08),
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 15),
                  label: const Text(ShellStrings.profileEditName),
                ),
              ],
              const SizedBox(height: 16),
              _InfoChip(
                icon: Icons.mail_outline_rounded,
                label: ShellStrings.profileLabelEmail,
                value: email.isNotEmpty ? email : '—',
              ),
              const SizedBox(height: 8),
              _InfoChip(
                icon: Icons.badge_outlined,
                label: 'Rôle',
                value: rolesLabel,
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
      email: email,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.4 : 0.65,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
