import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/logic/address/postal_address.dart';
import '../../../../core/logic/address/postal_address_suggestion.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import 'ban_address_search_field.dart';
import '../register/logic/register_wizard_constants.dart';
import '../register/widgets/form/register_field_row.dart';
import 'auth_step_section.dart';

/// Voie, numéro, code postal, ville et pays (inscription / devenir prestataire).
class PostalAddressForm extends StatelessWidget {
  const PostalAddressForm({
    super.key,
    required this.voieType,
    required this.onVoieTypeChanged,
    required this.voieNomController,
    required this.numeroController,
    required this.codePostalController,
    required this.villeController,
    required this.paysController,
    this.dense = true,
    this.enabled = true,
    this.onSurfaceVariant,
    this.villeError,
    this.codePostalError,
    this.adresseError,
    this.onVilleChanged,
    this.onCodePostalChanged,
    this.onAddressChanged,
    this.onSuggestionSelected,
    this.villeRequired = false,
    this.showSectionHeader = true,
    this.compactSection = true,
    this.enableBanSearch = true,
  });

  final String voieType;
  final ValueChanged<String> onVoieTypeChanged;
  final TextEditingController voieNomController;
  final TextEditingController numeroController;
  final TextEditingController codePostalController;
  final TextEditingController villeController;
  final TextEditingController paysController;
  final bool dense;
  final bool enabled;
  final Color? onSurfaceVariant;
  final String? villeError;
  final String? codePostalError;
  final String? adresseError;
  final VoidCallback? onVilleChanged;
  final VoidCallback? onCodePostalChanged;
  final VoidCallback? onAddressChanged;
  final ValueChanged<PostalAddressSuggestion>? onSuggestionSelected;
  final bool villeRequired;
  final bool showSectionHeader;
  final bool compactSection;
  final bool enableBanSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = onSurfaceVariant ?? theme.colorScheme.onSurfaceVariant;
    final fieldGap = dense
        ? RegisterWizardConstants.fieldGap
        : RegisterWizardConstants.fieldGap + 2;

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (enableBanSearch) ...[
          BanAddressSearchField(
            countryLabel: paysController.text,
            enabled: enabled,
            dense: dense,
            onSelected: (suggestion) {
              final address = suggestion.address;
              onVoieTypeChanged(address.voieType);
              numeroController.text = address.numero;
              voieNomController.text = address.voieNom;
              codePostalController.text = address.codePostal;
              villeController.text = address.ville;
              paysController.text = address.pays;
              onSuggestionSelected?.call(suggestion);
              onAddressChanged?.call();
            },
          ),
          SizedBox(height: fieldGap),
        ],
        DropdownButtonFormField<String>(
          value: PostalVoieTypes.all.contains(voieType)
              ? voieType
              : PostalVoieTypes.defaultType,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: AuthStrings.registerFieldVoieType,
            filled: true,
            isDense: dense,
          ),
          items: [
            for (final type in PostalVoieTypes.all)
              DropdownMenuItem(value: type, child: Text(type)),
          ],
          onChanged: enabled
              ? (value) {
                  if (value != null) {
                    onVoieTypeChanged(value);
                    onAddressChanged?.call();
                  }
                }
              : null,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontFamily: AppFonts.body,
          ),
        ),
        SizedBox(height: fieldGap),
        RegisterFieldRow(
          left: AppTextField(
            dense: dense,
            controller: numeroController,
            onChanged: onAddressChanged == null ? null : (_) => onAddressChanged!(),
            enabled: enabled,
            label: AuthStrings.registerFieldStreetNumber,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(Icons.tag_outlined, color: iconColor),
          ),
          right: AppTextField(
            dense: dense,
            controller: voieNomController,
            onChanged: onAddressChanged == null ? null : (_) => onAddressChanged!(),
            enabled: enabled,
            label: AuthStrings.registerFieldVoieName,
            errorText: adresseError,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(Icons.signpost_outlined, color: iconColor),
          ),
        ),
        SizedBox(height: fieldGap),
        RegisterFieldRow(
          left: AppTextField(
            dense: dense,
            controller: codePostalController,
            onChanged: onCodePostalChanged == null
                ? null
                : (_) => onCodePostalChanged!(),
            enabled: enabled,
            label: AuthStrings.registerFieldPostalCode,
            errorText: codePostalError,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(
              Icons.markunread_mailbox_outlined,
              color: iconColor,
            ),
          ),
          right: AppTextField(
            dense: dense,
            controller: villeController,
            onChanged:
                onVilleChanged == null ? null : (_) => onVilleChanged!(),
            enabled: enabled,
            label: villeRequired
                ? AuthStrings.registerFieldVille
                : AuthStrings.registerFieldVilleOptional,
            errorText: villeError,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(Icons.location_city_outlined, color: iconColor),
          ),
        ),
        SizedBox(height: fieldGap),
        AppTextField(
          dense: dense,
          controller: paysController,
          onChanged: onAddressChanged == null ? null : (_) => onAddressChanged!(),
          enabled: enabled,
          label: AuthStrings.registerFieldCountry,
          textInputAction: TextInputAction.done,
          prefixIcon: Icon(Icons.public_outlined, color: iconColor),
        ),
      ],
    );

    if (!showSectionHeader) return fields;

    return AuthStepSection(
      compact: compactSection,
      title: AuthStrings.registerSectionLocation,
      icon: Icons.location_city_outlined,
      child: fields,
    );
  }
}
