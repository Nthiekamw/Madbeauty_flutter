import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/widgets/auth_step_section.dart';

class EditClientAccountForm extends StatelessWidget {
  const EditClientAccountForm({
    super.key,
    required this.prenomController,
    required this.nomController,
    required this.phoneController,
    required this.cityController,
    required this.email,
    this.prenomError,
    this.nomError,
    this.errorText,
  });

  final TextEditingController prenomController;
  final TextEditingController nomController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final String email;
  final String? prenomError;
  final String? nomError;
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
              const SizedBox(height: 12),
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
        const SizedBox(height: 16),
        AuthStepSection(
          compact: true,
          title: DiscProfile.editAccountSectionContact,
          icon: Icons.contact_phone_outlined,
          child: Column(
            children: [
              AppTextField(
                dense: true,
                controller: phoneController,
                label: DiscProfile.labelPhone,
                hint: AuthStrings.registerFieldPhoneHint,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 6),
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
        const SizedBox(height: 16),
        AuthStepSection(
          compact: true,
          title: DiscProfile.editAccountSectionLocation,
          icon: Icons.location_city_outlined,
          child: AppTextField(
            dense: true,
            controller: cityController,
            label: DiscProfile.labelCity,
            hint: AuthStrings.registerFieldAdresse,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: onSurfaceVariant,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
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
