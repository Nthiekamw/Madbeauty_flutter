import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_forgot_password_link.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../../widgets/auth_google_button.dart';
import '../../widgets/auth_or_divider.dart';

/// Page de connexion : e-mail + mot de passe, Google.
class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.showSupabaseConfigCard,
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.submitError,
    required this.isLoading,
    required this.formEnabled,
    required this.onBack,
    required this.onSubmitPassword,
    required this.onOpenRegister,
    required this.onPasswordFieldSubmitted,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onGoogle,
    required this.onForgotPassword,
  });

  final bool showSupabaseConfigCard;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final String? submitError;
  final bool isLoading;
  final bool formEnabled;
  final VoidCallback onBack;
  final VoidCallback onSubmitPassword;
  final VoidCallback onOpenRegister;
  final VoidCallback onPasswordFieldSubmitted;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onGoogle;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthFormScaffold(
      title: AuthStrings.loginTitle,
      subtitle: AuthStrings.loginDescription,
      onBack: onBack,
      isBackEnabled: !isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showSupabaseConfigCard) ...[
            _SupabaseConfigCard(),
            const SizedBox(height: 20),
          ],
          AuthFormCard(
            child: Column(
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
                    color: theme.colorScheme.onSurfaceVariant,
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
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                AuthForgotPasswordLink(
                  enabled: formEnabled && !isLoading,
                  onPressed: onForgotPassword,
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
                  onPressed: onSubmitPassword,
                  child: Text(
                    AuthStrings.loginActionSubmit,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const AuthOrDivider(),
          AuthGoogleButton(
            label: AuthStrings.loginActionGoogle,
            enabled: formEnabled && !isLoading,
            onPressed: onGoogle,
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: isLoading ? null : onOpenRegister,
              child: Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'Pas encore de compte ? '),
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
    );
  }
}

class _SupabaseConfigCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuthFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ShellStrings.supabaseMissingTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ShellStrings.supabaseMissingBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.body,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
