import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../logic/register_wizard_draft.dart';
import '../logic/register_wizard_submit_handler.dart';
import '../storage/register_pending_password_store.dart';
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
  final _submitHandler = RegisterWizardSubmitHandler();
  bool _redirecting = false;
  bool _resending = false;
  bool _checkingVerification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_continueIfSessionReady());
    });
  }

  Future<void> _continueIfSessionReady() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted || _redirecting || _checkingVerification) return;
    if (_hasActiveSession) {
      await _continueAfterVerification();
    }
  }

  bool get _hasActiveSession {
    return ref.read(authServiceProvider).currentSession?.user != null ||
        ref.read(authNotifierProvider).value != null;
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
        adresse: draft.adresse,
        voieType: draft.voieType,
        voieNom: draft.voieNom,
        numeroRue: draft.numeroRue,
        pays: draft.pays,
        salon: draft.salon,
        nomAffiche: draft.nomAffiche,
        codePostal: draft.codePostal,
        description: draft.description,
        ville: draft.ville,
        bio: draft.bio,
        signedUpViaOAuth: draft.signedUpViaOAuth,
        pendingGoogleSignIn: draft.pendingGoogleSignIn,
        phoneRequiredOnExtras: draft.phoneRequiredOnExtras,
        pendingEmailVerification: pendingEmailVerification,
        role: draft.role,
        clientDefaultAvatarUrl: draft.clientDefaultAvatarUrl,
      ),
    );
  }

  Future<void> _goBack() async {
    if (_checkingVerification || _redirecting) return;
    await _persistDraft(pendingEmailVerification: false);
    await RegisterPendingPasswordStore.instance.clear();
    if (!mounted) return;
    context.goRegister();
  }

  Future<void> _continueAfterVerification() async {
    if (!mounted || _redirecting || _checkingVerification) return;

    setState(() => _checkingVerification = true);

    try {
      final user = await _submitHandler.resolveVerifiedUser(
        ref: ref,
        email: widget.email,
      );
      if (!mounted) return;

      if (user == null) {
        AppSnackBar.info(context, AuthStrings.registerEmailVerifyStillPending);
        setState(() => _checkingVerification = false);
        return;
      }

      _redirecting = true;
      await _submitHandler.finalizePendingRegistrationFromDraft(
        context: context,
        mounted: () => mounted,
        ref: ref,
        session: user,
      );
    } on AppFailure catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.message);
      setState(() {
        _checkingVerification = false;
        _redirecting = false;
      });
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, CoreStrings.errorUnexpected);
      setState(() {
        _checkingVerification = false;
        _redirecting = false;
      });
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

    ref.listen(authNotifierProvider, (prev, next) {
      final user = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      final hadUser = switch (prev) {
        AsyncData(:final value) => value != null,
        _ => false,
      };
      if (user != null && !hadUser && !_redirecting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_continueAfterVerification());
        });
      }
    });

    ref.listen(authStateStreamProvider, (prev, next) {
      final event = next.value?.event;
      if (event != AuthChangeEvent.signedIn || _redirecting) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_continueAfterVerification());
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
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _checkingVerification || _redirecting
                    ? null
                    : () => unawaited(_continueAfterVerification()),
                icon: _checkingVerification
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.mark_email_read_outlined),
                label: Text(
                  _checkingVerification
                      ? AuthStrings.registerEmailVerifyChecking
                      : AuthStrings.registerEmailVerifyConfirmedCta,
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
