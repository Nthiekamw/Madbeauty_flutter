import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/user_role.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/auth_form_styles.dart';
import '../../../../../shared/widgets/app/app_text_field.dart';
import '../../../../../shared/widgets/phone/phone_number_field.dart';
import '../../../widgets/auth_form_card.dart';
import '../../../widgets/auth_google_button.dart';
import '../../../widgets/auth_or_divider.dart';
import '../../../widgets/auth_role_card.dart';
import '../../../widgets/auth_step_section.dart';
import '../../logic/register_wizard_constants.dart';
import '../../providers/register_wizard_form_controller.dart';
import '../register_client_avatar_picker.dart';
import '../../../../prestataire/widgets/shared/prestataire_signup_extras_form.dart';
import '../../../widgets/postal_address_form.dart';
import '../form/register_field_row.dart';

class RegisterWizardIdentityStep extends StatelessWidget {
  const RegisterWizardIdentityStep({
    super.key,
    required this.form,
    required this.formEnabled,
    required this.onSurfaceVariant,
    required this.onGoogleSignIn,
  });

  final RegisterWizardFormController form;
  final bool formEnabled;
  final Color onSurfaceVariant;
  final VoidCallback? onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    return AuthFormCard(
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!form.signedUpViaOAuth) ...[
            AuthStepSection(
              compact: true,
              title: AuthStrings.registerSectionQuick,
              subtitle: AuthStrings.registerSectionQuickHint,
              icon: Icons.bolt_outlined,
              child: AuthGoogleButton(
                label: AuthStrings.registerActionGoogle,
                enabled: formEnabled,
                isLoading: form.googleSigningIn,
                onPressed: onGoogleSignIn,
              ),
            ),
            const SizedBox(height: RegisterWizardConstants.sectionGap),
            const AuthOrDivider(compact: true),
            const SizedBox(height: RegisterWizardConstants.sectionGap),
          ],
          AuthStepSection(
            compact: true,
            title: AuthStrings.registerSectionIdentity,
            icon: Icons.person_outline_rounded,
            child: RegisterFieldRow(
              left: AppTextField(
                dense: true,
                controller: form.prenom,
                onChanged: (_) => form.clearPrenomError(),
                enabled: formEnabled,
                label: AuthStrings.registerFieldPrenom,
                errorText: form.prenomError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
              ),
              right: AppTextField(
                dense: true,
                controller: form.nom,
                onChanged: (_) => form.clearNomError(),
                enabled: formEnabled,
                label: AuthStrings.registerFieldNom,
                errorText: form.nomError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
              ),
            ),
          ),
          const SizedBox(height: RegisterWizardConstants.sectionGap),
          AuthStepSection(
            compact: true,
            title: AuthStrings.registerSectionContact,
            icon: Icons.phone_outlined,
            child: PhoneNumberField(
              dense: true,
              enabled: formEnabled,
              localController: form.phone,
              dialCode: form.phoneDialCode,
              errorText: form.phoneError,
              onDialCodeChanged: form.setPhoneDialCode,
              onLocalChanged: form.clearPhoneError,
            ),
          ),
          const SizedBox(height: RegisterWizardConstants.sectionGap),
          AuthStepSection(
            compact: true,
            title: AuthStrings.loginFieldEmail,
            icon: Icons.mail_outline_rounded,
            child: AppTextField(
              dense: true,
              controller: form.email,
              onChanged: (_) => form.clearEmailError(),
              enabled: formEnabled && !form.signedUpViaOAuth,
              label: AuthStrings.loginFieldEmail,
              errorText: form.emailError,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.next,
              autofillHints: const [
                AutofillHints.email,
                AutofillHints.username,
              ],
              prefixIcon: Icon(
                Icons.mail_outline,
                color: onSurfaceVariant,
              ),
            ),
          ),
          if (form.signedUpViaOAuth) ...[
            const SizedBox(height: RegisterWizardConstants.sectionGap),
            const RegisterWizardGoogleConnectedBanner(),
          ],
          if (!form.signedUpViaOAuth) ...[
            const SizedBox(height: RegisterWizardConstants.sectionGap),
            AuthStepSection(
              compact: true,
              title: AuthStrings.registerSectionSecurity,
              icon: Icons.lock_outline_rounded,
              child: Column(
                children: [
                  AppTextField(
                    dense: true,
                    controller: form.password,
                    onChanged: (_) => form.clearPasswordError(),
                    enabled: formEnabled,
                    label: AuthStrings.loginFieldPassword,
                    hint: AuthStrings.registerFieldPasswordHint,
                    errorText: form.passwordError,
                    obscureText: form.obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: onSurfaceVariant,
                    ),
                    suffixIcon: IconButton(
                      tooltip: form.obscurePassword
                          ? AuthStrings.loginShowPassword
                          : AuthStrings.loginHidePassword,
                      onPressed: formEnabled ? form.toggleObscurePassword : null,
                      icon: Icon(
                        form.obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: RegisterWizardConstants.fieldGap),
                  AppTextField(
                    dense: true,
                    controller: form.confirm,
                    onChanged: (_) => form.clearConfirmError(),
                    enabled: formEnabled,
                    label: AuthStrings.registerFieldConfirmPassword,
                    errorText: form.confirmError,
                    obscureText: form.obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: onSurfaceVariant,
                    ),
                    suffixIcon: IconButton(
                      tooltip: form.obscureConfirmPassword
                          ? AuthStrings.loginShowPassword
                          : AuthStrings.loginHidePassword,
                      onPressed:
                          formEnabled ? form.toggleObscureConfirmPassword : null,
                      icon: Icon(
                        form.obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RegisterWizardRoleStep extends StatelessWidget {
  const RegisterWizardRoleStep({
    super.key,
    required this.form,
    required this.formEnabled,
    required this.theme,
    required this.onSurfaceVariant,
  });

  final RegisterWizardFormController form;
  final bool formEnabled;
  final ThemeData theme;
  final Color onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    return AuthFormCard(
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AuthStrings.roleChoiceDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              color: onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: RegisterWizardConstants.sectionGap),
          AuthRoleCard(
            compact: true,
            selected: form.roleChoice == UserRole.client,
            title: AuthStrings.registerChooseClient,
            subtitle: AuthStrings.registerChooseClientHint,
            icon: Icons.spa_outlined,
            onTap: formEnabled
                ? () => form.selectRole(UserRole.client)
                : null,
          ),
          const SizedBox(height: RegisterWizardConstants.fieldGap),
          AuthRoleCard(
            compact: true,
            selected: form.roleChoice == UserRole.prestataire,
            title: AuthStrings.registerChoosePresta,
            subtitle: AuthStrings.registerChoosePrestaHint,
            icon: Icons.storefront_outlined,
            onTap: formEnabled
                ? () => form.selectRole(UserRole.prestataire)
                : null,
          ),
        ],
      ),
    );
  }
}

class RegisterWizardExtrasStep extends StatelessWidget {
  const RegisterWizardExtrasStep({
    super.key,
    required this.form,
    required this.formEnabled,
    required this.onSurfaceVariant,
    required this.onPickClientAvatar,
  });

  final RegisterWizardFormController form;
  final bool formEnabled;
  final Color onSurfaceVariant;
  final Future<void> Function() onPickClientAvatar;

  @override
  Widget build(BuildContext context) {
    return AuthFormCard(
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!form.isPresta) ...[
            RegisterClientAvatarPicker(
              form: form,
              formEnabled: formEnabled,
              onPickPhoto: () => unawaited(onPickClientAvatar()),
            ),
            const SizedBox(height: RegisterWizardConstants.sectionGap),
            PostalAddressForm(
              dense: true,
              enabled: formEnabled,
              onSurfaceVariant: onSurfaceVariant,
              voieType: form.voieType,
              onVoieTypeChanged: form.setVoieType,
              voieNomController: form.voieNom,
              numeroController: form.numeroRue,
              codePostalController: form.codePostal,
              villeController: form.ville,
              paysController: form.pays,
            ),
          ] else ...[
            PrestataireSignupExtrasForm(
              dense: true,
              enabled: formEnabled,
              onSurfaceVariant: onSurfaceVariant,
              salonController: form.salon,
              voieType: form.voieType,
              onVoieTypeChanged: form.setVoieType,
              voieNomController: form.voieNom,
              numeroController: form.numeroRue,
              codePostalController: form.codePostal,
              villeController: form.ville,
              paysController: form.pays,
              nomAfficheController: form.nomAffiche,
              descriptionController: form.description,
              bioController: form.bio,
              salonError: form.salonError,
              villeError: form.villeError,
              onSalonChanged: form.clearSalonError,
              onVilleChanged: form.clearVilleError,
            ),
            const SizedBox(height: RegisterWizardConstants.sectionGap),
            RegisterPrestaSubscriptionHint(onSurfaceVariant: onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}

class RegisterPrestaSubscriptionHint extends StatelessWidget {
  const RegisterPrestaSubscriptionHint({required this.onSurfaceVariant});

  final Color onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.card_membership_outlined,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              DiscPrestaSub.registerHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterWizardGoogleConnectedBanner extends StatelessWidget {
  const RegisterWizardGoogleConnectedBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AuthFormStyles.bannerRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AuthStrings.registerGoogleConnectedBanner,
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
