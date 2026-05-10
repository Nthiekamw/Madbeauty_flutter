import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle),
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
                AppStrings.registerDescription,
                style: Theme.of(context).textTheme.bodyMedium,
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
                          AppStrings.supabaseMissingTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.supabaseMissingBody,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              AppTextField(
                controller: nameController,
                onChanged: onNameChanged,
                enabled: formEnabled,
                textInputAction: TextInputAction.next,
                label: AppStrings.registerFieldName,
                errorText: nameError,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: emailController,
                onChanged: onEmailChanged,
                enabled: formEnabled,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                autocorrect: false,
                textInputAction: TextInputAction.next,
                label: AppStrings.loginFieldEmail,
                errorText: emailError,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: passwordController,
                onChanged: onPasswordChanged,
                enabled: formEnabled,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onPasswordFieldSubmitted(),
                label: AppStrings.loginFieldPassword,
                errorText: passwordError,
              ),
              if (submitError != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      submitError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
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
                onPressed: onSubmit,
                child: const Text(AppStrings.registerActionSubmit),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isLoading ? null : onOpenLogin,
                child: const Text(AppStrings.registerActionBackToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
