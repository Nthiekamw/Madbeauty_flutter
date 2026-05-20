import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({
    super.key,
    required this.passwordController,
    required this.confirmController,
    required this.passwordError,
    required this.confirmError,
    required this.submitError,
    required this.isLoading,
    required this.formEnabled,
    required this.onSubmit,
    required this.onPasswordChanged,
    required this.onConfirmChanged,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String? passwordError;
  final String? confirmError;
  final String? submitError;
  final bool isLoading;
  final bool formEnabled;
  final VoidCallback onSubmit;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return AuthFormScaffold(
      title: AuthStrings.resetPasswordRecoveryHeadline,
      subtitle: AuthStrings.resetPasswordRecoveryHint,
      showLogo: true,
      onBack: () {},
      isBackEnabled: false,
      child: AuthFormCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.lock_reset, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AuthStrings.resetPasswordTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: passwordController,
              onChanged: onPasswordChanged,
              enabled: formEnabled,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              label: AuthStrings.loginFieldPassword,
              errorText: passwordError,
              prefixIcon: Icon(Icons.lock_outline, color: muted),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: confirmController,
              onChanged: onConfirmChanged,
              enabled: formEnabled,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              label: AuthStrings.resetPasswordFieldConfirm,
              errorText: confirmError,
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
              child: Text(
                AuthStrings.resetPasswordActionSubmit,
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
    );
  }
}

/// Lien recovery expiré ou ouvert hors de l’app.
class ResetPasswordInvalidLinkPage extends StatelessWidget {
  const ResetPasswordInvalidLinkPage({
    super.key,
    required this.onRequestNewLink,
    required this.onBackToLogin,
  });

  final VoidCallback onRequestNewLink;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return AuthFormScaffold(
      title: AuthStrings.resetPasswordLinkInvalidTitle,
      subtitle: AuthStrings.resetPasswordLinkInvalidBody,
      showLogo: true,
      onBack: onBackToLogin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFormCard(
            child: Column(
              children: [
                Icon(
                  Icons.link_off_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                AppButton(
                  onPressed: onRequestNewLink,
                  child: const Text(AuthStrings.resetPasswordRequestNewLink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBackToLogin,
            child: const Text(AuthStrings.guestCtaLogin),
          ),
        ],
      ),
    );
  }
}
