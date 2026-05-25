import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/prototype_layout.dart';
import '../../../shared/theme/prototype_palette.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/prototype/prototype_white_header_bar.dart';

/// En-tête profil : carte hero (dark) ou bandeau blanc (style Madbeauty_flutter).
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

    if (isDark) {
      return _DarkProfileHeader(
        profile: profile,
        displayName: displayName,
        email: email,
        rolesLabel: rolesLabel,
        avatarBytes: avatarBytes,
        onEditPhoto: onEditPhoto,
        onEditName: onEditName,
        photoLoading: photoLoading,
      );
    }

    final layout = PrototypeLayout(context);
    final rem = layout.rem;

    return PrototypeWhiteHeaderBar(
      padding: EdgeInsets.fromLTRB(rem * 4, rem * 6, rem * 4, rem * 6),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: rem * 24,
                height: rem * 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PrototypePalette.gold, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: PrototypePalette.gold.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _AvatarPreview(
                  radius: rem * 11.5,
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
                      color: Colors.white.withValues(alpha: 0.6),
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
                )
              else if (onEditPhoto != null)
                GestureDetector(
                  onTap: onEditPhoto,
                  child: Container(
                    width: rem * 8,
                    height: rem * 8,
                    decoration: BoxDecoration(
                      color: PrototypePalette.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: rem * 4.5,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: rem * 4),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rem * 5.5,
              fontWeight: FontWeight.w800,
              color: PrototypePalette.textDark,
            ),
          ),
          SizedBox(height: rem),
          Text(
            rolesLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rem * 3.5,
              color: PrototypePalette.textGrey,
            ),
          ),
          if (onEditName != null) ...[
            SizedBox(height: rem * 2),
            TextButton.icon(
              onPressed: onEditName,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(ShellStrings.profileEditName),
            ),
          ],
          SizedBox(height: rem * 3),
          Text(
            email.isNotEmpty ? email : '—',
            style: TextStyle(
              fontSize: rem * 3.2,
              color: PrototypePalette.textMed,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkProfileHeader extends StatelessWidget {
  const _DarkProfileHeader({
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
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
              theme.colorScheme.surface.withValues(alpha: 0.75),
            ],
          ),
          border: Border.all(color: primary.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primary.withValues(alpha: 0.25),
                        width: 2.5,
                      ),
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
                    )
                  else if (onEditPhoto != null)
                    Material(
                      color: primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onEditPhoto,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: Colors.white,
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
                  fontWeight: FontWeight.w800,
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
              Text(
                email.isNotEmpty ? email : '—',
                style: theme.textTheme.bodyMedium,
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
