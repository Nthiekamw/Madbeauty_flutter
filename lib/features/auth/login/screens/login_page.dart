import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_button.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_forgot_password_link.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../../widgets/auth_google_button.dart';
import '../../widgets/auth_or_divider.dart';
import '../../widgets/auth_step_section.dart';

/// Page de connexion : Google, e-mail + mot de passe.
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
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return AuthFormScaffold(
      title: AuthStrings.loginTitle,
      subtitle: AuthStrings.loginDescription,
      showLogo: true,
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
            const SizedBox(height: 16),
          ],
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthStepSection(
                  title: AuthStrings.loginSectionCredentials,
                  icon: Icons.lock_outline_rounded,
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
                  ),
                ),
                if (submitError != null) ...[
                  const SizedBox(height: 16),
                  AuthErrorBanner(message: submitError!),
                ],
                if (formEnabled) ...[
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

