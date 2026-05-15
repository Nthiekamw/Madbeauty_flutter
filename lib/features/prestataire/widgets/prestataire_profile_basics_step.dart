import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_text_field.dart';

class PrestataireProfileBasicsStep extends StatelessWidget {
  const PrestataireProfileBasicsStep({
    super.key,
    required this.nomController,
    required this.bioController,
    required this.villeController,
    required this.avatarUrl,
    required this.avatarBytes,
    required this.nomError,
    required this.bioError,
    required this.villeError,
    required this.avatarError,
    required this.uploadProgress,
    required this.onPickAvatar,
    required this.onChanged,
  });

  final TextEditingController nomController;
  final TextEditingController bioController;
  final TextEditingController villeController;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final String? nomError;
  final String? bioError;
  final String? villeError;
  final String? avatarError;
  final double? uploadProgress;
  final VoidCallback onPickAvatar;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar =
        avatarBytes != null ||
        (avatarUrl != null && avatarUrl!.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaForm.avatarLabel,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _AvatarPreview(
              avatarBytes: avatarBytes,
              avatarUrl: avatarUrl,
              displayName: nomController.text,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPickAvatar,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(
                  hasAvatar
                      ? DiscPrestaForm.avatarChange
                      : DiscPrestaForm.avatarPick,
                ),
              ),
            ),
          ],
        ),
        if (avatarError != null) ...[
          const SizedBox(height: 8),
          Text(
            avatarError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (uploadProgress != null) ...[
          const SizedBox(height: 10),
          LinearProgressIndicator(value: uploadProgress),
          const SizedBox(height: 6),
          Text(
            DiscPrestaForm.uploadingAvatar,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        AppTextField(
          controller: nomController,
          label: DiscPrestaForm.salonName,
          errorText: nomError,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: bioController,
          label: DiscPrestaForm.bio,
          hint: DiscPrestaForm.bioHint,
          errorText: bioError,
          minLines: 3,
          maxLines: 5,
          inputFormatters: [LengthLimitingTextInputFormatter(300)],
          onChanged: (_) => onChanged(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${bioController.text.characters.length}/300'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: villeController,
          label: DiscPrestaForm.city,
          errorText: villeError,
          textInputAction: TextInputAction.done,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.avatarBytes,
    required this.avatarUrl,
    required this.displayName,
  });

  final Uint8List? avatarBytes;
  final String? avatarUrl;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final bytes = avatarBytes;
    if (bytes == null) {
      return AppAvatar(
        imageUrl: avatarUrl,
        displayName: displayName,
        radius: 36,
      );
    }

    return ClipOval(
      child: Image.memory(bytes, width: 72, height: 72, fit: BoxFit.cover),
    );
  }
}
