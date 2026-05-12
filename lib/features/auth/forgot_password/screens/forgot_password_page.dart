import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({
    super.key,
    required this.emailController,
    required this.emailError,
    required this.submitError,
    required this.successMessage,
    required this.isLoading,
    required this.formEnabled,
    required this.onBack,
    required this.onSubmit,
    required this.onEmailChanged,
  });

  final TextEditingController emailController;
  final String? emailError;
  final String? submitError;
  final String? successMessage;
  final bool isLoading;
  final bool formEnabled;
  final VoidCallback onBack;
  final VoidCallback onSubmit;
  final ValueChanged<String> onEmailChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AuthStrings.forgotPasswordTitle),
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
                AuthStrings.forgotPasswordDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: emailController,
                onChanged: onEmailChanged,
                enabled: formEnabled,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                label: AuthStrings.loginFieldEmail,
                errorText: emailError,
              ),
              if (successMessage != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      successMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                  ),
                ),
              ],
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
                child: Text(AuthStrings.forgotPasswordSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
