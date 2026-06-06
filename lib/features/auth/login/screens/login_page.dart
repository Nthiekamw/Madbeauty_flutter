import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_button.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import '../../../../shared/widgets/phone/phone_number_field.dart';
import '../../widgets/auth_credential_method_toggle.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_forgot_password_link.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../../widgets/auth_google_button.dart';
import '../../widgets/auth_or_divider.dart';
import '../models/login_credential_method.dart';

/// Page de connexion : Google, e-mail + mot de passe ou téléphone + OTP.
class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.showSupabaseConfigCard,
    required this.credentialMethod,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.phoneDialCode,
    required this.onPhoneDialCodeChanged,
    required this.emailError,
    required this.passwordError,
    required this.phoneError,
    required this.submitError,
    required this.infoMessage,
    required this.isLoading,
    required this.formEnabled,
    required this.onBack,
    required this.onSubmit,
    required this.onOpenRegister,
    required this.onPasswordFieldSubmitted,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onPhoneChanged,
    required this.onCredentialMethodChanged,
    required this.onGoogle,
    required this.onForgotPassword,
  });

  final bool showSupabaseConfigCard;
  final LoginCredentialMethod credentialMethod;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final String phoneDialCode;
  final ValueChanged<String> onPhoneDialCodeChanged;
  final String? emailError;
  final String? passwordError;
  final String? phoneError;
  final String? submitError;
  final String? infoMessage;
  final bool isLoading;
  final bool formEnabled;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onOpenRegister;
  final VoidCallback onPasswordFieldSubmitted;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<bool> onCredentialMethodChanged;
  final VoidCallback onGoogle;
  final VoidCallback onForgotPassword;

  bool get _isPhone => credentialMethod == LoginCredentialMethod.phone;

  String get _primaryLabel =>
      _isPhone ? AuthStrings.loginActionSendOtp : AuthStrings.loginActionSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return AuthFormScaffold(
      title: AuthStrings.loginTitle,
      showLogo: true,
      logoWidth: 168,
      showLogoTagline: false,
      showTitle: true,
      centerTitle: true,
      scrollable: true,
      onBack: onBack,
      isBackEnabled: !isLoading,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            variant: AppButtonVariant.primary,
            isLoading: isLoading,
            enabled: formEnabled,
            onPressed: onSubmit,
            child: Text(
              _primaryLabel,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: isLoading ? null : onOpenRegister,
              child: Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    color: onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: AuthStrings.loginNoAccountPrompt),
                    TextSpan(
                      text: AuthStrings.loginActionOpenRegister,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showSupabaseConfigCard) ...[
            const _SupabaseConfigCard(),
            const SizedBox(height: 12),
          ],
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthCredentialMethodToggle(
                  emailLabel: AuthStrings.loginPasswordTabEmail,
                  phoneLabel: AuthStrings.loginPasswordTabPhone,
                  isPhoneSelected: _isPhone,
                  enabled: formEnabled,
                  compact: true,
                  onChanged: onCredentialMethodChanged,
                ),
                const SizedBox(height: 16),
                if (_isPhone)
                  _PhoneCredentialsFields(
                    phoneController: phoneController,
                    phoneDialCode: phoneDialCode,
                    onPhoneDialCodeChanged: onPhoneDialCodeChanged,
                    phoneError: phoneError,
                    formEnabled: formEnabled,
                    onPhoneChanged: onPhoneChanged,
                  )
                else
                  _EmailCredentialsFields(
                    emailController: emailController,
                    passwordController: passwordController,
                    emailError: emailError,
                    passwordError: passwordError,
                    formEnabled: formEnabled,
                    isLoading: isLoading,
                    onEmailChanged: onEmailChanged,
                    onPasswordChanged: onPasswordChanged,
                    onPasswordFieldSubmitted: onPasswordFieldSubmitted,
                    onForgotPassword: onForgotPassword,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                if (infoMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    infoMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: AppFonts.body,
                      color: theme.colorScheme.primary,
                      height: 1.4,
                    ),
                  ),
                ],
                if (submitError != null) ...[
                  const SizedBox(height: 12),
                  AuthErrorBanner(message: submitError!),
                ],
                if (formEnabled) ...[
                  const SizedBox(height: 16),
                  const AuthOrDivider(compact: true),
                  AuthGoogleButton(
                    label: AuthStrings.loginActionGoogle,
                    enabled: !isLoading,
                    onPressed: onGoogle,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailCredentialsFields extends StatelessWidget {
  const _EmailCredentialsFields({
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.formEnabled,
    required this.isLoading,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onPasswordFieldSubmitted,
    required this.onForgotPassword,
    required this.onSurfaceVariant,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final bool formEnabled;
  final bool isLoading;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onPasswordFieldSubmitted;
  final VoidCallback onForgotPassword;
  final Color onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: emailController,
          onChanged: onEmailChanged,
          enabled: formEnabled,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [
            AutofillHints.username,
            AutofillHints.email,
          ],
          autocorrect: false,
          textInputAction: TextInputAction.next,
          label: AuthStrings.loginFieldEmail,
          errorText: emailError,
          prefixIcon: Icon(
            Icons.mail_outline,
            color: onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: passwordController,
          onChanged: onPasswordChanged,
          enabled: formEnabled,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onPasswordFieldSubmitted(),
          label: AuthStrings.loginFieldPassword,
          errorText: passwordError,
          prefixIcon: Icon(
            Icons.lock_outline,
            color: onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: AuthForgotPasswordLink(
            enabled: formEnabled && !isLoading,
            onPressed: onForgotPassword,
          ),
        ),
      ],
    );
  }
}

class _PhoneCredentialsFields extends StatelessWidget {
  const _PhoneCredentialsFields({
    required this.phoneController,
    required this.phoneDialCode,
    required this.onPhoneDialCodeChanged,
    required this.phoneError,
    required this.formEnabled,
    required this.onPhoneChanged,
  });

  final TextEditingController phoneController;
  final String phoneDialCode;
  final ValueChanged<String> onPhoneDialCodeChanged;
  final String? phoneError;
  final bool formEnabled;
  final ValueChanged<String> onPhoneChanged;

  @override
  Widget build(BuildContext context) {
    return PhoneNumberField(
      localController: phoneController,
      dialCode: phoneDialCode,
      errorText: phoneError,
      enabled: formEnabled,
      dense: true,
      onDialCodeChanged: onPhoneDialCodeChanged,
      onLocalChanged: () => onPhoneChanged(phoneController.text),
    );
  }
}

class _SupabaseConfigCard extends StatelessWidget {
  const _SupabaseConfigCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ShellStrings.supabaseMissingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ShellStrings.supabaseMissingBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.body,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
