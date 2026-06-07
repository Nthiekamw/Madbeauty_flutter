import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../../../../shared/theme/app_colors.dart';
import '../logic/register_wizard_draft.dart';
import '../storage/register_wizard_draft_store.dart';

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
  final _passwordController = TextEditingController();
  bool _redirecting = false;
  bool _resending = false;
  bool _checkingVerification = false;
  bool _obscurePassword = true;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    final draft = RegisterWizardDraftStore.instance.read();
    final draftPassword = draft?.password.trim() ?? '';
    if (draftPassword.isNotEmpty) {
      _passwordController.text = draftPassword;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_continueIfSessionReady());
    });
  }

  /// Après ouverture via le lien e-mail (`token_hash`), la session peut
  /// s’ouvrir juste après le premier frame.
  Future<void> _continueIfSessionReady() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted || _redirecting || _checkingVerification) return;
    final user = ref.read(authServiceProvider).currentSession?.user;
    if (user != null) {
      await _continueAfterVerification();
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String get _password =>
      _passwordController.text.trim().isNotEmpty
          ? _passwordController.text.trim()
          : (RegisterWizardDraftStore.instance.read()?.password.trim() ?? '');

  Future<User?> _resolveVerifiedUser() async {
    final authService = ref.read(authServiceProvider);
    final email = widget.email.trim();
    final password = _password;

    // Session déjà ouverte (lien cliqué sur ce téléphone, token_hash traité).
    var user = authService.currentSession?.user ??
        ref.read(authNotifierProvider).value;
    if (user != null) return user;

    if (email.isEmpty || password.isEmpty) return null;

    try {
      await authService.refreshSession();
    } catch (_) {}

    user = authService.currentSession?.user ??
        ref.read(authNotifierProvider).value;
    if (user != null) return user;

    // Connexion : fonctionne si le lien a été ouvert sur un autre appareil.
    try {
      return await ref.read(authNotifierProvider.notifier).signInWithPassword(
            email: email,
            password: password,
          );
    } on AppFailure catch (e) {
      if (_isEmailNotConfirmed(e)) return null;
      rethrow;
    }
  }

  bool _isEmailNotConfirmed(AppFailure failure) {
    final cause = failure.cause;
    if (cause is AuthException) {
      return FailureMapper.fromAuthException(cause).message ==
          AuthStrings.authEmailNotConfirmed;
    }
    return failure.message == AuthStrings.authEmailNotConfirmed;
  }

  Future<void> _persistDraft({
    required bool pendingEmailVerification,
  }) async {
    final draft = RegisterWizardDraftStore.instance.read();
    if (draft == null) return;
    await RegisterWizardDraftStore.instance.save(
      RegisterWizardDraft(
        step: draft.step,
        prenom: draft.prenom,
        nom: draft.nom,
        phone: draft.phone,
        phoneDialCode: draft.phoneDialCode,
        email: draft.email,
        password: _password.isNotEmpty ? _password : draft.password,
        confirmPassword: draft.confirmPassword,
        adresse: draft.adresse,
        salon: draft.salon,
        nomAffiche: draft.nomAffiche,
        codePostal: draft.codePostal,
        description: draft.description,
        ville: draft.ville,
        bio: draft.bio,
        signedUpViaOAuth: draft.signedUpViaOAuth,
        pendingGoogleSignIn: draft.pendingGoogleSignIn,
        signedUpViaPhone: draft.signedUpViaPhone,
        phoneRequiredOnExtras: draft.phoneRequiredOnExtras,
        pendingEmailVerification: pendingEmailVerification,
        pendingPhoneVerification: draft.pendingPhoneVerification,
        role: draft.role,
      ),
    );
  }

  Future<void> _goBack() async {
    if (_checkingVerification || _redirecting) return;
    await _persistDraft(pendingEmailVerification: false);
    if (!mounted) return;
    context.goRegister();
  }

  Future<void> _continueAfterVerification() async {
    if (!mounted || _redirecting || _checkingVerification) return;

    if (_password.isEmpty) {
      setState(
        () => _passwordError = AuthStrings.registerEmailVerifyPasswordRequired,
      );
      return;
    }

    setState(() {
      _checkingVerification = true;
      _passwordError = null;
    });

    try {
      final user = await _resolveVerifiedUser();
      if (!mounted) return;

      if (user == null) {
        AppSnackBar.info(context, AuthStrings.registerEmailVerifyStillPending);
        setState(() => _checkingVerification = false);
        return;
      }

      await _persistDraft(pendingEmailVerification: false);
      if (!mounted) return;

      _redirecting = true;
      setState(() => _checkingVerification = false);
      context.goRegisterResume();
    } on AppFailure catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.message);
      setState(() => _checkingVerification = false);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, CoreStrings.errorUnexpected);
      setState(() => _checkingVerification = false);
    }
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
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    ref.listen(authNotifierProvider, (prev, next) {
      final user = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final hadUser = switch (prev) {
        AsyncData(:final value) => value != null,
        _ => false,
      };
      if (user != null && !hadUser) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _continueAfterVerification();
        });
      }
    });

    ref.listen(authStateStreamProvider, (prev, next) {
      final event = next.value?.event;
      if (event != AuthChangeEvent.signedIn) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _continueAfterVerification();
      });
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_goBack());
      },
      child: AuthFormScaffold(
        title: AuthStrings.registerEmailVerifyTitle,
        subtitle: AuthStrings.registerEmailVerifySubtitle(widget.email),
        showLogo: false,
        compact: true,
        scrollable: true,
        isBackEnabled: !_checkingVerification && !_redirecting,
        onBack: () => unawaited(_goBack()),
        child: AuthFormCard(
        compact: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AuthStrings.registerEmailVerifyBody,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              AuthStrings.registerEmailVerifyPasswordHint,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: AppFonts.body,
                color: onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              dense: true,
              controller: _passwordController,
              onChanged: (_) => setState(() => _passwordError = null),
              enabled: !_checkingVerification,
              label: AuthStrings.loginFieldPassword,
              errorText: _passwordError,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              prefixIcon: Icon(
                Icons.lock_outline,
                color: onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? AuthStrings.loginShowPassword
                    : AuthStrings.loginHidePassword,
                onPressed: _checkingVerification
                    ? null
                    : () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: onSurfaceVariant,
                ),
              ),
              onSubmitted: (_) => _continueAfterVerification(),
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
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
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
      ),
    );
  }
}
