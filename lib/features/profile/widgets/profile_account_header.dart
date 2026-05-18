import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../shared/widgets/app_avatar.dart';

/// En-tête profil : photo, nom, e-mail, rôle.
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              _AvatarPreview(
                radius: 48,
                imageUrl: profile?.avatarUrl,
                displayName: displayName,
                email: email,
                avatarBytes: avatarBytes,
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
              if (onEditPhoto != null && !photoLoading)
                Material(
                  color: theme.colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onEditPhoto,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.camera_alt_outlined,
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
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onEditName != null) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: onEditName,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(ShellStrings.profileEditName),
            ),
          ],
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.mail_outline,
            label: ShellStrings.profileLabelEmail,
            value: email.isNotEmpty ? email : '—',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Rôle',
            value: rolesLabel,
          ),
        ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
