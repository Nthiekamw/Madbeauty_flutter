import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import '../../../../shared/widgets/phone/phone_number_field.dart';
import '../../../auth/widgets/postal_address_form.dart';
import '../../../auth/widgets/auth_step_section.dart';

class EditClientAccountForm extends StatelessWidget {
  const EditClientAccountForm({
    super.key,
    required this.prenomController,
    required this.nomController,
    required this.phoneController,
    required this.phoneDialCode,
    required this.onPhoneDialCodeChanged,
    this.onPhoneChanged,
    required this.voieType,
    required this.onVoieTypeChanged,
    required this.voieNomController,
    required this.numeroController,
    required this.codePostalController,
    required this.cityController,
    required this.countryController,
    this.onAddressChanged,
    required this.email,
    this.prenomError,
    this.nomError,
    this.phoneError,
    this.errorText,
  });

  final TextEditingController prenomController;
  final TextEditingController nomController;
  final TextEditingController phoneController;
  final String phoneDialCode;
  final ValueChanged<String> onPhoneDialCodeChanged;
  final VoidCallback? onPhoneChanged;
  final String voieType;
  final ValueChanged<String> onVoieTypeChanged;
  final TextEditingController voieNomController;
  final TextEditingController numeroController;
  final TextEditingController codePostalController;
  final TextEditingController cityController;
  final TextEditingController countryController;
  final VoidCallback? onAddressChanged;
  final String email;
  final String? prenomError;
  final String? nomError;
  final String? phoneError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStepSection(
          compact: true,
          title: DiscProfile.editAccountSectionIdentity,
          icon: Icons.person_outline_rounded,
          child: Column(
            children: [
              AppTextField(
                dense: true,
                controller: prenomController,
                label: ShellStrings.profileFieldPrenom,
                errorText: prenomError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                prefixIcon: Icon(
                  Icons.badge_outlined,
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                dense: true,
                controller: nomController,
                label: ShellStrings.profileFieldNom,
                errorText: nomError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                prefixIcon: Icon(
                  Icons.badge_outlined,
                  color: onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AuthStepSection(
          compact: true,
          title: DiscProfile.editAccountSectionContact,
          icon: Icons.contact_phone_outlined,
          child: Column(
            children: [
              PhoneNumberField(
                dense: true,
                localController: phoneController,
                dialCode: phoneDialCode,
                errorText: phoneError,
                onDialCodeChanged: onPhoneDialCodeChanged,
                onLocalChanged: onPhoneChanged,
              ),
              const SizedBox(height: 8),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: DiscProfile.labelEmail,
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: onSurfaceVariant,
                  ),
                  filled: true,
                  enabled: false,
                ),
                child: Text(
                  email.isNotEmpty ? email : '—',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DiscProfile.editAccountEmailHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AuthStepSection(
          compact: true,
          title: DiscProfile.editAccountSectionLocation,
          icon: Icons.location_city_outlined,
          child: PostalAddressForm(
            dense: true,
            showSectionHeader: false,
            compactSection: true,
            voieType: voieType,
            onVoieTypeChanged: onVoieTypeChanged,
            voieNomController: voieNomController,
            numeroController: numeroController,
            codePostalController: codePostalController,
            villeController: cityController,
            paysController: countryController,
            onAddressChanged: onAddressChanged,
            onVilleChanged: onAddressChanged,
            onCodePostalChanged: onAddressChanged,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                errorText!,
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

