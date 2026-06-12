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

/// Page de connexion : Google ou e-mail + mot de passe.
class LoginPage extends StatefulWidget {
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
    required this.onSubmit,
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
  final VoidCallback onSubmit;
  final VoidCallback onOpenRegister;
  final VoidCallback onPasswordFieldSubmitted;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onGoogle;
  final VoidCallback onForgotPassword;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return AuthFormScaffold(
      title: AuthStrings.loginTitle,
      showLogo: true,
      logoWidth: 168,
      showLogoTagline: false,
      showTitle: true,
      centerTitle: true,
      scrollable: true,
      onBack: widget.onBack,
      isBackEnabled: !widget.isLoading,
      bottomBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            variant: AppButtonVariant.primary,
            isLoading: widget.isLoading,
            enabled: widget.formEnabled,
            onPressed: widget.onSubmit,
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
              onPressed: widget.isLoading ? null : widget.onOpenRegister,
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
          if (widget.showSupabaseConfigCard) ...[
            const _SupabaseConfigCard(),
            const SizedBox(height: 12),
          ],
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: widget.emailController,
                  onChanged: widget.onEmailChanged,
                  enabled: widget.formEnabled,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  label: AuthStrings.loginFieldEmail,
                  errorText: widget.emailError,
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: widget.passwordController,
                  onChanged: widget.onPasswordChanged,
                  enabled: widget.formEnabled,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onPasswordFieldSubmitted(),
                  label: AuthStrings.loginFieldPassword,
                  errorText: widget.passwordError,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: onSurfaceVariant,
                  ),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? AuthStrings.loginShowPassword
                        : AuthStrings.loginHidePassword,
                    onPressed: widget.formEnabled
                        ? () => setState(() => _obscurePassword = !_obscurePassword)
                        : null,
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: AuthForgotPasswordLink(
                    enabled: widget.formEnabled && !widget.isLoading,
                    onPressed: widget.onForgotPassword,
                  ),
                ),
                if (widget.submitError != null) ...[
                  const SizedBox(height: 12),
                  AuthErrorBanner(message: widget.submitError!),
                ],
                if (widget.formEnabled) ...[
                  const SizedBox(height: 16),
                  const AuthOrDivider(compact: true),
                  AuthGoogleButton(
                    label: AuthStrings.loginActionGoogle,
                    enabled: !widget.isLoading,
                    onPressed: widget.onGoogle,
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
