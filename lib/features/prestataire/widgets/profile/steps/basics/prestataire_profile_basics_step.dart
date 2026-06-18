import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/user/lieu_travail.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/widgets/app/app_avatar.dart';
import '../../../../../../shared/widgets/app/app_network_image.dart';
import '../../../../../../shared/widgets/app/app_text_field.dart';
import 'package:madbeauty/features/auth/widgets/postal_address_form.dart';
import '../../hub/prestataire_hub_layout.dart';
import '../../../../logic/professional_experience_entries.dart';
import 'prestataire_professional_experience_picker.dart';
import 'prestataire_work_location_selector.dart';
import '../../../../../../shared/theme/app_colors.dart';

class PrestataireProfileBasicsStep extends StatelessWidget {
  const PrestataireProfileBasicsStep({
    super.key,
    required this.nomController,
    required this.nomAfficheController,
    required this.descriptionController,
    required this.experienceProController,
    required this.anneesExperienceController,
    required this.professionalExperiences,
    required this.onToggleProfessionalExperience,
    required this.onProfessionalExperienceYearsChanged,
    required this.onRemoveProfessionalExperience,
    required this.bioController,
    required this.villeController,
    required this.codePostalController,
    required this.adresseController,
    required this.voieType,
    required this.onVoieTypeChanged,
    required this.voieNomController,
    required this.numeroRueController,
    required this.paysController,
    required this.onPostalAddressChanged,
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
    this.guidedMode = false,
  });

  final bool vitrineOnly;
  final bool locationOnly;
  final bool guidedMode;

  final TextEditingController nomController;
  final TextEditingController nomAfficheController;
  final TextEditingController descriptionController;
  final TextEditingController experienceProController;
  final TextEditingController anneesExperienceController;
  final List<ProfessionalExperienceEntry> professionalExperiences;
  final ValueChanged<String> onToggleProfessionalExperience;
  final void Function(String role, String years) onProfessionalExperienceYearsChanged;
  final ValueChanged<String> onRemoveProfessionalExperience;
  final TextEditingController bioController;
  final TextEditingController villeController;
  final TextEditingController codePostalController;
  final TextEditingController adresseController;
  final String voieType;
  final ValueChanged<String> onVoieTypeChanged;
  final TextEditingController voieNomController;
  final TextEditingController numeroRueController;
  final TextEditingController paysController;
  final VoidCallback onPostalAddressChanged;
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

    final identityBlock = _buildIdentityBlock(
      theme: theme,
      layout: layout,
      avatarPreview: avatarPreview,
      pickPhotoButton: pickPhotoButton,
      hasAvatar: hasAvatar,
    );
    final presentationBlock = _buildPresentationBlock();
    final locationBlock = _buildLocationBlock(context, layout);

    if (!guidedMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showVitrine) ...[identityBlock, presentationBlock],
          if (showLocation) locationBlock,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showVitrine) ...[
          PrestataireHubFormSection(
            index: 1,
            title: DiscPrestaForm.hubSectionIdentity,
            subtitle: DiscPrestaForm.hubSectionIdentityHint,
            icon: Icons.photo_camera_outlined,
            child: identityBlock,
          ),
          const SizedBox(height: PrestataireHubLayout.sectionGap),
          PrestataireHubFormSection(
            index: 2,
            title: DiscPrestaForm.hubSectionPresentation,
            subtitle: DiscPrestaForm.hubSectionPresentationHint,
            icon: Icons.description_outlined,
            child: presentationBlock,
          ),
        ],
        if (showLocation) ...[
          const SizedBox(height: PrestataireHubLayout.sectionGap),
          PrestataireHubFormSection(
            index: showVitrine ? 3 : 1,
            title: DiscPrestaForm.hubSectionWorkPlace,
            subtitle: DiscPrestaForm.hubSectionWorkPlaceHint,
            icon: Icons.home_work_outlined,
            child: _buildWorkLocationOnly(),
          ),
          const SizedBox(height: PrestataireHubLayout.sectionGap),
          PrestataireHubFormSection(
            index: showVitrine ? 4 : 2,
            title: DiscPrestaForm.hubSectionAddress,
            subtitle: DiscPrestaForm.hubSectionAddressHint,
            icon: Icons.location_on_outlined,
            child: _buildAddressFieldsOnly(context, layout),
          ),
        ],
      ],
    );
  }

  Widget _buildIdentityBlock({
    required ThemeData theme,
    required DiscoveryResponsive layout,
    required Widget avatarPreview,
    required Widget pickPhotoButton,
    required bool hasAvatar,
  }) {
    final displayName = nomAfficheController.text.isNotEmpty
        ? nomAfficheController.text
        : nomController.text;
    final guidedAvatar = avatarBytes != null
        ? ClipOval(
            child: Image.memory(
              avatarBytes!,
              width: 104,
              height: 104,
              fit: BoxFit.cover,
            ),
          )
        : AppAvatar(
            imageUrl: avatarUrl,
            displayName: displayName,
            radius: 52,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!guidedMode)
          Text(DiscPrestaForm.avatarLabel, style: theme.textTheme.labelLarge),
        if (!guidedMode) const SizedBox(height: 8),
        if (guidedMode) ...[
          Center(child: guidedAvatar),
          const SizedBox(height: 12),
          Text(
            DiscPrestaForm.hubAvatarPickHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: pickPhotoButton),
        ] else if (layout.useSideBySideFormRows)
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
        SizedBox(height: guidedMode ? 12 : 16),
        if (defaultAvatarUrls.isNotEmpty && onSelectDefaultAvatar != null) ...[
          Text('Photos par defaut', style: theme.textTheme.labelLarge),
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
                    selectedDefaultAvatarUrl != null &&
                    selectedDefaultAvatarUrl == url;
                return _DefaultAvatarChip(
                  imageUrl: url,
                  selected: selected,
                  onTap: () => onSelectDefaultAvatar?.call(url),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
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
      ],
    );
  }

  Widget _buildPresentationBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        PrestataireProfessionalExperiencePicker(
          entries: professionalExperiences,
          errorText: experienceProError,
          onToggleRole: onToggleProfessionalExperience,
          onYearsChanged: onProfessionalExperienceYearsChanged,
          onRemove: onRemoveProfessionalExperience,
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
    );
  }

  Widget _buildWorkLocationOnly() {
    return PrestataireWorkLocationSelector(
      value: lieuTravail,
      errorText: lieuTravailError,
      onChanged: onLieuTravailChanged,
    );
  }

  Widget _buildAddressFieldsOnly(
    BuildContext context,
    DiscoveryResponsive layout,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PostalAddressForm(
          voieType: voieType,
          onVoieTypeChanged: onVoieTypeChanged,
          voieNomController: voieNomController,
          numeroController: numeroRueController,
          codePostalController: codePostalController,
          villeController: villeController,
          paysController: paysController,
          villeError: villeError,
          codePostalError: codePostalError,
          onVilleChanged: () {
            onPostalAddressChanged();
            onChanged();
          },
          onCodePostalChanged: () {
            onPostalAddressChanged();
            onChanged();
          },
          villeRequired: true,
          showSectionHeader: false,
          dense: true,
        ),
        if (adresseError != null) ...[
          const SizedBox(height: 8),
          Text(
            adresseError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationBlock(
    BuildContext context,
    DiscoveryResponsive layout,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWorkLocationOnly(),
        const SizedBox(height: 12),
        _buildAddressFieldsOnly(context, layout),
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
      color: AppColors.transparent,
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
            child: AppNetworkImage(
              url: imageUrl,
              fit: BoxFit.cover,
              error: ColoredBox(
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
