import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_text_field.dart';
import 'prestataire_work_location_selector.dart';

class PrestataireProfileBasicsStep extends StatelessWidget {
  const PrestataireProfileBasicsStep({
    super.key,
    required this.nomController,
    required this.nomAfficheController,
    required this.descriptionController,
    required this.experienceProController,
    required this.anneesExperienceController,
    required this.bioController,
    required this.villeController,
    required this.codePostalController,
    required this.adresseController,
    required this.lieuTravail,
    required this.avatarUrl,
    required this.avatarBytes,
    required this.nomError,
    required this.nomAfficheError,
    required this.descriptionError,
    required this.experienceProError,
    required this.villeError,
    required this.codePostalError,
    required this.adresseError,
    required this.lieuTravailError,
    required this.avatarError,
    required this.uploadProgress,
    required this.onPickAvatar,
    required this.onLieuTravailChanged,
    required this.onChanged,
    this.vitrineOnly = false,
    this.locationOnly = false,
  });

  final bool vitrineOnly;
  final bool locationOnly;

  final TextEditingController nomController;
  final TextEditingController nomAfficheController;
  final TextEditingController descriptionController;
  final TextEditingController experienceProController;
  final TextEditingController anneesExperienceController;
  final TextEditingController bioController;
  final TextEditingController villeController;
  final TextEditingController codePostalController;
  final TextEditingController adresseController;
  final LieuTravail? lieuTravail;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final String? nomError;
  final String? nomAfficheError;
  final String? descriptionError;
  final String? experienceProError;
  final String? villeError;
  final String? codePostalError;
  final String? adresseError;
  final String? lieuTravailError;
  final String? avatarError;
  final double? uploadProgress;
  final VoidCallback onPickAvatar;
  final ValueChanged<LieuTravail> onLieuTravailChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar =
        avatarBytes != null ||
        (avatarUrl != null && avatarUrl!.trim().isNotEmpty);

    final showVitrine = !locationOnly;
    final showLocation = !vitrineOnly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showVitrine) ...[
        Text(DiscPrestaForm.avatarLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            _AvatarPreview(
              avatarBytes: avatarBytes,
              avatarUrl: avatarUrl,
              displayName: nomAfficheController.text.isNotEmpty
                  ? nomAfficheController.text
                  : nomController.text,
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
          controller: nomAfficheController,
          label: DiscPrestaForm.displayName,
          hint: DiscPrestaForm.displayNameHint,
          errorText: nomAfficheError,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: descriptionController,
          label: DiscPrestaForm.description,
          hint: DiscPrestaForm.descriptionHint,
          errorText: descriptionError,
          minLines: 2,
          maxLines: 4,
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
          onChanged: (_) => onChanged(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${descriptionController.text.characters.length}/200'),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: experienceProController,
          label: DiscPrestaForm.experiencePro,
          hint: DiscPrestaForm.experienceProHint,
          errorText: experienceProError,
          minLines: 2,
          maxLines: 3,
          inputFormatters: [LengthLimitingTextInputFormatter(150)],
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: anneesExperienceController,
          label: DiscPrestaForm.experienceYears,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: bioController,
          label: DiscPrestaForm.bio,
          hint: DiscPrestaForm.bioHint,
          minLines: 2,
          maxLines: 4,
          onChanged: (_) => onChanged(),
        ),
        ],
        if (showLocation) ...[
        const SizedBox(height: 16),
        PrestataireWorkLocationSelector(
          value: lieuTravail,
          errorText: lieuTravailError,
          onChanged: onLieuTravailChanged,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: adresseController,
          label: DiscPrestaForm.salonAddress,
          hint: DiscPrestaForm.salonAddressHint,
          errorText: adresseError,
          maxLines: 2,
          textInputAction: TextInputAction.next,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppTextField(
                controller: codePostalController,
                label: DiscPrestaForm.postalCode,
                hint: DiscPrestaForm.postalCodeHint,
                errorText: codePostalError,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: AppTextField(
                controller: villeController,
                label: DiscPrestaForm.city,
                errorText: villeError,
                textInputAction: TextInputAction.done,
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
        ],
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
