import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../auth/register/logic/register_wizard_constants.dart';
import '../../../auth/register/widgets/form/register_field_row.dart';
import '../../../auth/register/widgets/form/register_optional_panel.dart';
import '../../../auth/widgets/auth_step_section.dart';
import '../../../../shared/widgets/app/app_text_field.dart';

/// Champs activité / localisation prestataire (inscription + devenir prestataire).
class PrestataireSignupExtrasForm extends StatelessWidget {
  const PrestataireSignupExtrasForm({
    super.key,
    required this.salonController,
    required this.villeController,
    required this.codePostalController,
    required this.nomAfficheController,
    required this.descriptionController,
    required this.adresseController,
    required this.bioController,
    this.dense = true,
    this.enabled = true,
    this.onSurfaceVariant,
    this.salonError,
    this.villeError,
    this.codePostalError,
    this.onSalonChanged,
    this.onVilleChanged,
    this.onCodePostalChanged,
    this.formError,
    this.showOptionalPanel = true,
  });

  final TextEditingController salonController;
  final TextEditingController villeController;
  final TextEditingController codePostalController;
  final TextEditingController nomAfficheController;
  final TextEditingController descriptionController;
  final TextEditingController adresseController;
  final TextEditingController bioController;
  final bool dense;
  final bool enabled;
  final Color? onSurfaceVariant;
  final String? salonError;
  final String? villeError;
  final String? codePostalError;
  final VoidCallback? onSalonChanged;
  final VoidCallback? onVilleChanged;
  final VoidCallback? onCodePostalChanged;
  final String? formError;
  final bool showOptionalPanel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = onSurfaceVariant ?? theme.colorScheme.onSurfaceVariant;
    final gap = dense
        ? RegisterWizardConstants.sectionGap
        : RegisterWizardConstants.sectionGap + 4;

    final optionalFields = [
      AppTextField(
        dense: dense,
        controller: nomAfficheController,
        enabled: enabled,
        label: AuthStrings.registerFieldDisplayName,
        prefixIcon: Icon(Icons.badge_outlined, color: iconColor),
      ),
      SizedBox(height: dense ? RegisterWizardConstants.fieldGap : 12),
      AppTextField(
        dense: dense,
        controller: descriptionController,
        enabled: enabled,
        label: AuthStrings.registerFieldDescriptionPresta,
        maxLines: 2,
        prefixIcon: Icon(Icons.short_text_outlined, color: iconColor),
      ),
      SizedBox(height: dense ? RegisterWizardConstants.fieldGap : 12),
      AppTextField(
        dense: dense,
        controller: adresseController,
        enabled: enabled,
        label: AuthStrings.registerFieldSalonAdresse,
        maxLines: 2,
        prefixIcon: Icon(Icons.location_on_outlined, color: iconColor),
      ),
      SizedBox(height: dense ? RegisterWizardConstants.fieldGap : 12),
      AppTextField(
        dense: dense,
        controller: bioController,
        enabled: enabled,
        label: AuthStrings.registerFieldBioPresta,
        maxLines: dense ? 2 : 3,
        prefixIcon: Icon(Icons.notes_outlined, color: iconColor),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStepSection(
          compact: dense,
          title: AuthStrings.registerSectionActivity,
          subtitle: AuthStrings.registerSectionActivityHint,
          icon: Icons.storefront_outlined,
          child: AppTextField(
            dense: dense,
            controller: salonController,
            onChanged: onSalonChanged == null ? null : (_) => onSalonChanged!(),
            enabled: enabled,
            label: AuthStrings.registerFieldSalon,
            errorText: salonError,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(Icons.storefront_outlined, color: iconColor),
          ),
        ),
        SizedBox(height: gap),
        AuthStepSection(
          compact: dense,
          title: AuthStrings.registerSectionLocation,
          icon: Icons.location_city_outlined,
          child: RegisterFieldRow(
            left: AppTextField(
              dense: dense,
              controller: villeController,
              onChanged: onVilleChanged == null ? null : (_) => onVilleChanged!(),
              enabled: enabled,
              label: AuthStrings.registerFieldVille,
              errorText: villeError,
              textInputAction: TextInputAction.next,
              prefixIcon: Icon(Icons.location_city_outlined, color: iconColor),
            ),
            right: AppTextField(
              dense: dense,
              controller: codePostalController,
              onChanged: onCodePostalChanged == null
                  ? null
                  : (_) => onCodePostalChanged!(),
              enabled: enabled,
              label: AuthStrings.registerFieldPostalCode,
              errorText: codePostalError,
              keyboardType: TextInputType.number,
              prefixIcon: Icon(
                Icons.markunread_mailbox_outlined,
                color: iconColor,
              ),
            ),
          ),
        ),
        if (showOptionalPanel) ...[
          SizedBox(height: gap),
          RegisterOptionalPanel(children: optionalFields),
        ] else ...[
          SizedBox(height: dense ? RegisterWizardConstants.fieldGap : 12),
          ...optionalFields,
        ],
        if (formError != null) ...[
          SizedBox(height: gap),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                formError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
