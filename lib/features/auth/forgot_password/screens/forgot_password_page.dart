import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/auth_form_styles.dart';
import '../../../../shared/widgets/app/app_button.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';

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
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final primary = theme.colorScheme.primary;
    final sent = successMessage != null;

    return AuthFormScaffold(
      title: AuthStrings.forgotPasswordTitle,
      subtitle: AuthStrings.forgotPasswordDescription,
      onBack: onBack,
      isBackEnabled: !isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 32,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: emailController,
                  onChanged: onEmailChanged,
                  enabled: formEnabled && !sent,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onSubmit(),
                  label: AuthStrings.loginFieldEmail,
                  errorText: emailError,
                  prefixIcon: Icon(Icons.mail_outline, color: muted),
                ),
                if (sent) ...[
                  const SizedBox(height: 18),
                  _SuccessBanner(message: successMessage!),
                  const SizedBox(height: 16),
                  _RecoveryStepsHint(),
                ],
                if (submitError != null) ...[
                  const SizedBox(height: 16),
                  AuthErrorBanner(message: submitError!),
                ],
                const SizedBox(height: 22),
                AppButton(
                  variant: AppButtonVariant.primary,
                  isLoading: isLoading,
                  enabled: formEnabled && !sent,
                  onPressed: onSubmit,
                  child: Text(
                    AuthStrings.forgotPasswordSubmit,
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
          if (sent) ...[
            const SizedBox(height: 14),
            Material(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.5 : 0.85,
              ),
              borderRadius: AuthFormStyles.cardBorderRadius,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.smartphone_outlined, size: 22, color: primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AuthStrings.forgotPasswordSuccessHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: muted,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(AuthFormStyles.bannerRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              size: 24,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveryStepsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepRow(
          number: '1',
          text: 'Ouvre l’e-mail sur ton téléphone',
          theme: theme,
        ),
        const SizedBox(height: 10),
        _StepRow(
          number: '2',
          text: 'Clique sur le lien de réinitialisation',
          theme: theme,
        ),
        const SizedBox(height: 10),
        _StepRow(
          number: '3',
          text: 'Choisis un nouveau mot de passe dans l’app',
          theme: theme,
        ),
        const SizedBox(height: 8),
        Text(
          'Le lien ouvre MadBeauty automatiquement.',
          style: theme.textTheme.labelSmall?.copyWith(
            fontFamily: AppFonts.body,
            color: muted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
    required this.theme,
  });

  final String number;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            number,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppFonts.body,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

