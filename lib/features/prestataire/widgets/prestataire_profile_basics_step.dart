import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../shared/layout/discovery_responsive.dart';
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
    this.defaultAvatarUrls = const [],
    this.selectedDefaultAvatarUrl,
    this.onSelectDefaultAvatar,
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
  final List<String> defaultAvatarUrls;
  final String? selectedDefaultAvatarUrl;
  final ValueChanged<String>? onSelectDefaultAvatar;
  final ValueChanged<LieuTravail> onLieuTravailChanged;
  final VoidCallback onChanged;

  String? _dropdownValueFor(
    TextEditingController controller,
    List<String> options,
  ) {
    final value = controller.text.trim();
    if (value.isEmpty) return null;
    return options.contains(value) ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = DiscoveryResponsive.of(context);
    final hasAvatar =
        avatarBytes != null ||
        (avatarUrl != null && avatarUrl!.trim().isNotEmpty);

    final showVitrine = !locationOnly;
    final showLocation = !vitrineOnly;
    final avatarPreview = _AvatarPreview(
      avatarBytes: avatarBytes,
      avatarUrl: avatarUrl,
      displayName: nomAfficheController.text.isNotEmpty
          ? nomAfficheController.text
          : nomController.text,
    );
    final pickPhotoButton = OutlinedButton.icon(
      onPressed: onPickAvatar,
      icon: const Icon(Icons.photo_camera_outlined),
      label: Text(
        hasAvatar ? DiscPrestaForm.avatarChange : DiscPrestaForm.avatarPick,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showVitrine) ...[
        Text(DiscPrestaForm.avatarLabel, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        if (layout.useSideBySideFormRows)
          Row(
            children: [
              avatarPreview,
              const SizedBox(width: 16),
              Expanded(child: pickPhotoButton),
            ],
          )
        else ...[
          Center(child: avatarPreview),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: pickPhotoButton),
        ],
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
        if (defaultAvatarUrls.isNotEmpty && onSelectDefaultAvatar != null) ...[
          Text(
            'Photos par defaut',
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: defaultAvatarUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final url = defaultAvatarUrls[index];
                final selected =
                    selectedDefaultAvatarUrl != null && selectedDefaultAvatarUrl == url;
                return _DefaultAvatarChip(
                  imageUrl: url,
                  selected: selected,
                  onTap: () => onSelectDefaultAvatar?.call(url),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
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
        DropdownButtonFormField<String>(
          value: _dropdownValueFor(
            experienceProController,
            DiscPrestaForm.experienceProSuggestions,
          ),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: DiscPrestaForm.experiencePro,
            hintText: DiscPrestaForm.experienceProHint,
            errorText: experienceProError,
            border: const OutlineInputBorder(),
          ),
          selectedItemBuilder: (context) => [
            for (final option in DiscPrestaForm.experienceProSuggestions)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          items: [
            for (final option in DiscPrestaForm.experienceProSuggestions)
              DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            experienceProController.text = value ?? '';
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _dropdownValueFor(
            anneesExperienceController,
            DiscPrestaForm.experienceYearsSuggestions,
          ),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: DiscPrestaForm.experienceYears,
            border: const OutlineInputBorder(),
          ),
          selectedItemBuilder: (context) => [
            for (final option in DiscPrestaForm.experienceYearsSuggestions)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          items: [
            for (final option in DiscPrestaForm.experienceYearsSuggestions)
              DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) {
            anneesExperienceController.text = value ?? '';
            onChanged();
          },
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
        if (layout.useSideBySideFormRows)
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
          )
        else ...[
          AppTextField(
            controller: codePostalController,
            label: DiscPrestaForm.postalCode,
            hint: DiscPrestaForm.postalCodeHint,
            errorText: codePostalError,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => onChanged(),
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

class _DefaultAvatarChip extends StatelessWidget {
  const _DefaultAvatarChip({
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? primary
                  : theme.colorScheme.outline.withValues(alpha: 0.25),
              width: selected ? 2.5 : 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.person_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
