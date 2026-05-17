import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(AuthStrings.loginTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AuthStrings.loginDescription,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (showSupabaseConfigCard) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ShellStrings.supabaseMissingTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ShellStrings.supabaseMissingBody,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
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
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: !formEnabled || isLoading ? null : onForgotPassword,
                  child: Text(AuthStrings.loginActionForgotPassword),
                ),
              ),
              const SizedBox(height: 8),
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
              ),
              if (submitError != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      submitError!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                variant: AppButtonVariant.primary,
                isLoading: isLoading,
                enabled: formEnabled,
                onPressed: onSubmitPassword,
                child: Text(AuthStrings.loginActionSubmit),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: !formEnabled || isLoading ? null : onGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: Text(AuthStrings.loginActionGoogle),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isLoading ? null : onOpenRegister,
                child: Text(AuthStrings.loginActionOpenRegister),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
