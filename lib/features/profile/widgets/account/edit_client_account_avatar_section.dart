import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/user/user_profile.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../../shared/theme/app_colors.dart';

class EditClientAccountAvatarSection extends StatelessWidget {
  const EditClientAccountAvatarSection({
    super.key,
    required this.displayName,
    required this.email,
    this.profile,
    this.avatarBytes,
    this.loading = false,
    this.onChangePhoto,
  });

  final String displayName;
  final String email;
  final UserProfile? profile;
  final Uint8List? avatarBytes;
  final bool loading;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
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
            if (loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: AppColors.scrimDark26,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
            if (!loading && onChangePhoto != null)
              Material(
                color: primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onChangePhoto,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (onChangePhoto != null && !loading) ...[
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: onChangePhoto,
            icon: const Icon(Icons.photo_outlined, size: 18),
            label: Text(ShellStrings.profileEditPhoto),
          ),
        ],
      ],
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

