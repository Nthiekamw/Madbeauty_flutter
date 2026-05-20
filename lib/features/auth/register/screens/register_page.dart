import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';

/// Formulaire d’inscription simple (legacy) — le flux principal est le wizard.
class RegisterPage extends StatelessWidget {
  const RegisterPage({
    super.key,
    required this.showSupabaseConfigCard,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.nameError,
    required this.emailError,
    required this.passwordError,
    required this.submitError,
    required this.isLoading,
    required this.formEnabled,
    required this.onBack,
    required this.onSubmit,
    required this.onPasswordFieldSubmitted,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onOpenLogin,
  });

  final bool showSupabaseConfigCard;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? submitError;
  final bool isLoading;
  final bool formEnabled;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final VoidCallback onPasswordFieldSubmitted;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onOpenLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AuthFormScaffold(
      title: AuthStrings.registerTitle,
      subtitle: AuthStrings.registerDescription,
      onBack: onBack,
      isBackEnabled: !isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showSupabaseConfigCard) ...[
            AuthFormCard(
              child: Text(
                ShellStrings.supabaseMissingBody,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 20),
          ],
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: nameController,
                  onChanged: onNameChanged,
                  enabled: formEnabled,
                  textInputAction: TextInputAction.next,
                  label: AuthStrings.registerFieldName,
                  errorText: nameError,
                  prefixIcon: Icon(Icons.person_outline, color: muted),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: emailController,
                  onChanged: onEmailChanged,
                  enabled: formEnabled,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  label: AuthStrings.loginFieldEmail,
                  errorText: emailError,
                  prefixIcon: Icon(Icons.mail_outline, color: muted),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: passwordController,
                  onChanged: onPasswordChanged,
                  enabled: formEnabled,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onPasswordFieldSubmitted(),
                  label: AuthStrings.loginFieldPassword,
                  errorText: passwordError,
                  prefixIcon: Icon(Icons.lock_outline, color: muted),
                ),
                if (submitError != null) ...[
                  const SizedBox(height: 16),
                  AuthErrorBanner(message: submitError!),
                ],
                const SizedBox(height: 20),
                AppButton(
                  variant: AppButtonVariant.primary,
                  isLoading: isLoading,
                  enabled: formEnabled,
                  onPressed: onSubmit,
                  child: const Text(AuthStrings.registerActionSubmit),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: isLoading ? null : onOpenLogin,
              child: Text(
                AuthStrings.registerActionBackToLogin,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
