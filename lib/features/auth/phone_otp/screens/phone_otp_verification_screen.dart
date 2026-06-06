import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_button.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';

/// Saisie du code SMS sur une page dédiée (connexion ou inscription).
class PhoneOtpVerificationScreen extends StatelessWidget {
  const PhoneOtpVerificationScreen({
    super.key,
    required this.phoneE164,
    required this.otpController,
    required this.otpError,
    required this.submitError,
    required this.infoMessage,
    required this.isBusy,
    required this.isResending,
    required this.formEnabled,
    required this.onBack,
    required this.onOtpChanged,
    required this.onVerify,
    required this.onResend,
  });

  final String phoneE164;
  final TextEditingController otpController;
  final String? otpError;
  final String? submitError;
  final String? infoMessage;
  final bool isBusy;
  final bool isResending;
  final bool formEnabled;
  final VoidCallback onBack;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return AuthFormScaffold(
      title: AuthStrings.phoneOtpVerifyTitle,
      subtitle: AuthStrings.phoneOtpVerifySubtitle(phoneE164),
      showLogo: false,
      compact: true,
      scrollable: true,
      onBack: onBack,
      isBackEnabled: !isBusy,
      bottomBar: AppButton(
        variant: AppButtonVariant.primary,
        isLoading: isBusy,
        enabled: formEnabled,
        onPressed: onVerify,
        child: Text(
          AuthStrings.loginActionVerifyOtp,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      child: AuthFormCard(
        compact: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AuthStrings.phoneOtpVerifyBody,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppTextField(
              dense: true,
              controller: otpController,
              onChanged: onOtpChanged,
              enabled: formEnabled && !isBusy,
              label: AuthStrings.loginFieldOtp,
              errorText: otpError,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onVerify(),
              prefixIcon: Icon(
                Icons.sms_outlined,
                color: onSurfaceVariant,
              ),
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
            const SizedBox(height: 8),
            TextButton(
              onPressed: isResending || isBusy ? null : onResend,
              child: isResending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AuthStrings.phoneOtpVerifyResendLabel),
            ),
          ],
        ),
      ),
    );
  }
}
