import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../models/auth_login_method.dart';

/// Page de connexion : mise en page uniquement (aucune règle métier).
class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.showSupabaseConfigCard,
    required this.authMethod,
    required this.onAuthMethodChanged,
    required this.emailController,
    required this.passwordController,
    required this.phoneController,
    required this.otpController,
    required this.emailError,
    required this.passwordError,
    required this.phoneError,
    required this.otpError,
    required this.submitError,
    required this.otpCodeSent,
    required this.isLoading,
    required this.formEnabled,
    required this.onBack,
    required this.onSubmitPassword,
    required this.onSendOtp,
    required this.onVerifyOtp,
    required this.onOpenRegister,
    required this.onPasswordFieldSubmitted,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onPhoneChanged,
    required this.onOtpChanged,
    required this.onGoogle,
    required this.onForgotPassword,
  });

  final bool showSupabaseConfigCard;
  final AuthLoginMethod authMethod;
  final ValueChanged<AuthLoginMethod> onAuthMethodChanged;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final TextEditingController otpController;
  final String? emailError;
  final String? passwordError;
  final String? phoneError;
  final String? otpError;
  final String? submitError;
  final bool otpCodeSent;
  final bool isLoading;
  final bool formEnabled;
  final VoidCallback onBack;
  final VoidCallback onSubmitPassword;
  final VoidCallback onSendOtp;
  final VoidCallback onVerifyOtp;
  final VoidCallback onOpenRegister;
  final VoidCallback onPasswordFieldSubmitted;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onGoogle;
  final VoidCallback onForgotPassword;

  bool get _submitIsOtpInfo =>
      submitError == AppStrings.loginOtpSentEmail ||
      submitError == AppStrings.loginOtpSentSms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.loginTitle),
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
                AppStrings.loginDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SegmentedButton<AuthLoginMethod>(
                segments: const [
                  ButtonSegment(
                    value: AuthLoginMethod.password,
                    label: Text(AppStrings.loginMethodPassword),
                    icon: Icon(Icons.password_outlined),
                  ),
                  ButtonSegment(
                    value: AuthLoginMethod.emailOtp,
                    label: Text(AppStrings.loginMethodEmailOtp),
                    icon: Icon(Icons.mail_outline),
                  ),
                  ButtonSegment(
                    value: AuthLoginMethod.phoneOtp,
                    label: Text(AppStrings.loginMethodPhoneOtp),
                    icon: Icon(Icons.sms_outlined),
                  ),
                ],
                selected: {authMethod},
                onSelectionChanged: isLoading
                    ? null
                    : (s) => onAuthMethodChanged(s.first),
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
              ..._buildFields(context),
              if (submitError != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: _submitIsOtpInfo
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      submitError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _submitIsOtpInfo
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                          ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: !formEnabled || isLoading ? null : onGoogle,
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: Text(AppStrings.loginActionGoogle),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: isLoading ? null : onOpenRegister,
                child: Text(AppStrings.loginActionOpenRegister),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields(BuildContext context) {
    switch (authMethod) {
      case AuthLoginMethod.password:
        return [
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
            label: AppStrings.loginFieldEmail,
            errorText: emailError,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: !formEnabled || isLoading ? null : onForgotPassword,
              child: Text(AppStrings.loginActionForgotPassword),
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
            label: AppStrings.loginFieldPassword,
            errorText: passwordError,
          ),
          const SizedBox(height: 24),
          AppButton(
            variant: AppButtonVariant.primary,
            isLoading: isLoading,
            enabled: formEnabled,
            onPressed: onSubmitPassword,
            child: Text(AppStrings.loginActionSubmit),
          ),
        ];
      case AuthLoginMethod.emailOtp:
        return [
          AppTextField(
            controller: emailController,
            onChanged: onEmailChanged,
            enabled: formEnabled,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            autocorrect: false,
            textInputAction: TextInputAction.next,
            label: AppStrings.loginFieldEmail,
            errorText: emailError,
          ),
          const SizedBox(height: 16),
          AppButton(
            variant: AppButtonVariant.secondary,
            isLoading: isLoading,
            enabled: formEnabled,
            onPressed: onSendOtp,
            child: Text(AppStrings.loginActionSendOtp),
          ),
          if (otpCodeSent) ...[
            const SizedBox(height: 16),
            AppTextField(
              controller: otpController,
              onChanged: onOtpChanged,
              enabled: formEnabled,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              label: AppStrings.loginFieldOtp,
              errorText: otpError,
            ),
            const SizedBox(height: 16),
            AppButton(
              variant: AppButtonVariant.primary,
              isLoading: isLoading,
              enabled: formEnabled,
              onPressed: onVerifyOtp,
              child: Text(AppStrings.loginActionVerifyOtp),
            ),
          ],
        ];
      case AuthLoginMethod.phoneOtp:
        return [
          AppTextField(
            controller: phoneController,
            onChanged: onPhoneChanged,
            enabled: formEnabled,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            textInputAction: TextInputAction.next,
            label: AppStrings.loginFieldPhone,
            errorText: phoneError,
          ),
          const SizedBox(height: 16),
          AppButton(
            variant: AppButtonVariant.secondary,
            isLoading: isLoading,
            enabled: formEnabled,
            onPressed: onSendOtp,
            child: Text(AppStrings.loginActionSendOtp),
          ),
          if (otpCodeSent) ...[
            const SizedBox(height: 16),
            AppTextField(
              controller: otpController,
              onChanged: onOtpChanged,
              enabled: formEnabled,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              label: AppStrings.loginFieldOtp,
              errorText: otpError,
            ),
            const SizedBox(height: 16),
            AppButton(
              variant: AppButtonVariant.primary,
              isLoading: isLoading,
              enabled: formEnabled,
              onPressed: onVerifyOtp,
              child: Text(AppStrings.loginActionVerifyOtp),
            ),
          ],
        ];
    }
  }
}
