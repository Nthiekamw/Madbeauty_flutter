import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.resetPasswordTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.resetPasswordDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: passwordController,
                onChanged: onPasswordChanged,
                enabled: formEnabled,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                label: AppStrings.loginFieldPassword,
                errorText: passwordError,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: confirmController,
                onChanged: onConfirmChanged,
                enabled: formEnabled,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                label: AppStrings.resetPasswordFieldConfirm,
                errorText: confirmError,
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
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
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
                child: Text(AppStrings.resetPasswordActionSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
