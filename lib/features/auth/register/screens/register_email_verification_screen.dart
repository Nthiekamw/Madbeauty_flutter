import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';

class RegisterEmailVerificationScreen extends ConsumerStatefulWidget {
  const RegisterEmailVerificationScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  ConsumerState<RegisterEmailVerificationScreen> createState() =>
      _RegisterEmailVerificationScreenState();
}

class _RegisterEmailVerificationScreenState
    extends ConsumerState<RegisterEmailVerificationScreen> {
  bool _redirecting = false;
  bool _resending = false;
  bool _checkingVerification = false;

  Future<void> _continueAfterVerification() async {
    if (!mounted || _redirecting || _checkingVerification) return;
    setState(() => _checkingVerification = true);
    final authService = ref.read(authServiceProvider);
    try {
      await authService.refreshSession();
    } catch (_) {
      // Pas bloquant: on vérifie ensuite l'état user actuel.
    }
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      if (!mounted) return;
      AppSnackBar.info(context, AuthStrings.registerEmailVerifyStillPending);
      setState(() => _checkingVerification = false);
      return;
    }
    _redirecting = true;
    setState(() => _checkingVerification = false);
    context.goRegisterResume();
  }

  Future<void> _resendEmail() async {
    final email = widget.email.trim();
    if (email.isEmpty || _resending) return;
    final authService = ref.read(authServiceProvider);

    setState(() => _resending = true);
    try {
      await authService.resendSignupConfirmationEmail(
        email: email,
        emailRedirectTo: AppConfig.authEmailRedirectTo,
      );
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: AuthStrings.registerEmailVerifyResendSuccess,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(
        context,
        AuthStrings.registerEmailVerifyResendError,
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (prev, next) {
      final user = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _continueAfterVerification();
        });
      }
    });

    return AuthFormScaffold(
      title: AuthStrings.registerEmailVerifyTitle,
      subtitle: AuthStrings.registerEmailVerifySubtitle(widget.email),
      showLogo: false,
      compact: true,
      scrollable: true,
      onBack: () => context.goWelcome(),
      child: AuthFormCard(
        compact: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AuthStrings.registerEmailVerifyBody,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _checkingVerification
                  ? null
                  : () => _continueAfterVerification(),
              icon: _checkingVerification
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.mark_email_read_outlined),
              label: Text(
                _checkingVerification
                    ? 'Vérification...'
                    : AuthStrings.registerEmailVerifyCta,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _resending ? null : _resendEmail,
              child: _resending
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AuthStrings.registerEmailVerifyResendLabel),
            ),
          ],
        ),
      ),
    );
  }
}

