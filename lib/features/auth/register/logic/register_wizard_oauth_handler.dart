import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../services/offline/offline_actions.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../providers/auth_notifier.dart' show authNotifierProvider, authServiceProvider;
import '../providers/register_wizard_form_controller.dart';

/// Google OAuth et reprise de session pour l'inscription wizard.
class RegisterWizardOAuthHandler {
  Timer? _googleSessionWatch;

  void dispose() => _stopGoogleSessionWatch();

  void startGoogleSessionWatch({
    required WidgetRef ref,
    required bool Function() mounted,
    required RegisterWizardFormController form,
    required Future<void> Function(User user) onOAuthConnected,
  }) {
    _stopGoogleSessionWatch();
    var ticks = 0;
    _googleSessionWatch = Timer.periodic(const Duration(milliseconds: 350), (_) {
      ticks++;
      if (!mounted() || !form.googleSigningIn) {
        _stopGoogleSessionWatch();
        return;
      }
      if (ticks > 180) {
        _stopGoogleSessionWatch();
        if (mounted()) form.setGoogleSigningIn(false);
        return;
      }
      final user = ref.read(authServiceProvider).currentSession?.user;
      if (user == null) return;
      unawaited(onOAuthConnected(user));
    });
  }

  void _stopGoogleSessionWatch() {
    _googleSessionWatch?.cancel();
    _googleSessionWatch = null;
  }

  Future<void> googleSignIn({
    required WidgetRef ref,
    required BuildContext context,
    required bool Function() mounted,
    required RegisterWizardFormController form,
    required Future<void> Function(User user) onOAuthConnected,
  }) async {
    FocusScope.of(context).unfocus();
    form.setError(null);

    if (!await ensureOnline(context, ref)) return;

    if (!AppConfig.hasSupabase) {
      form.setError(ShellStrings.supabaseMissingTitle);
      return;
    }

    final existingUser = ref.read(authServiceProvider).currentSession?.user;
    if (existingUser != null && isGoogleOAuthUser(existingUser)) {
      await onOAuthConnected(existingUser);
      return;
    }

    form.googleLaunched = true;
    form.setGoogleSigningIn(true);
    startGoogleSessionWatch(
      ref: ref,
      mounted: mounted,
      form: form,
      onOAuthConnected: onOAuthConnected,
    );

    try {
      final user =
          await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      _stopGoogleSessionWatch();
      if (!mounted()) return;
      if (user != null) {
        await onOAuthConnected(user);
        return;
      }
      await form.persistDraft(pendingGoogleSignIn: true);
      if (!mounted()) return;
      AppSnackBar.info(context, AuthStrings.loginGoogleStarted);
    } on AppFailure catch (e) {
      _stopGoogleSessionWatch();
      if (!mounted()) return;
      final recovered = await finishGoogleFromSessionIfAny(
        ref: ref,
        form: form,
        onOAuthConnected: onOAuthConnected,
      );
      if (recovered) return;
      form.setGoogleSigningIn(false);
      form.googleLaunched = false;
      form.setError(e.message);
      unawaited(form.persistDraft(pendingGoogleSignIn: false));
    } catch (_) {
      _stopGoogleSessionWatch();
      if (!mounted()) return;
      final recovered = await finishGoogleFromSessionIfAny(
        ref: ref,
        form: form,
        onOAuthConnected: onOAuthConnected,
      );
      if (recovered) return;
      form.setGoogleSigningIn(false);
      form.googleLaunched = false;
      form.setError(CoreStrings.errorUnexpected);
      unawaited(form.persistDraft(pendingGoogleSignIn: false));
    } finally {
      _stopGoogleSessionWatch();
      if (mounted() && form.googleSigningIn) {
        unawaited(finishGoogleFromSessionIfAny(
          ref: ref,
          form: form,
          onOAuthConnected: onOAuthConnected,
        ));
      }
    }
  }

  Future<bool> finishGoogleFromSessionIfAny({
    required WidgetRef ref,
    required RegisterWizardFormController form,
    required Future<void> Function(User user) onOAuthConnected,
  }) async {
    final user = ref.read(authServiceProvider).currentSession?.user;
    if (user == null) return false;
    await onOAuthConnected(user);
    return form.signedUpViaOAuth;
  }

  Future<void> onOAuthConnected({
    required WidgetRef ref,
    required BuildContext context,
    required bool Function() mounted,
    required RegisterWizardFormController form,
    required User user,
  }) async {
    if (form.signedUpViaOAuth) {
      form.setGoogleSigningIn(false);
      form.googleLaunched = false;
      form.pendingGoogleSignIn = false;
      _stopGoogleSessionWatch();
      return;
    }
    form.hydrateFromOAuthUser(
      user,
      viaApple: RegisterWizardOAuthHandler.isAppleOAuthUser(user),
    );
    final hints =
        ref.read(authNotifierProvider.notifier).consumeOAuthIdentityHints();
    if (hints != null) {
      form.applyOAuthIdentityHints(
        providedPrenom: hints.providedPrenom,
        providedNom: hints.providedNom,
        providedEmail: hints.providedEmail,
        viaApple: RegisterWizardOAuthHandler.isAppleOAuthUser(user),
      );
    }
    if (!mounted()) return;
    form.onOAuthConnected();
    _stopGoogleSessionWatch();
    AppSnackBar.success(
      context,
      isAppleOAuthUser(user)
          ? AuthStrings.registerAppleConnected
          : AuthStrings.registerGoogleConnected,
    );
    unawaited(form.persistDraft(pendingGoogleSignIn: false));
  }

  static bool isGoogleOAuthUser(User user) {
    return isOAuthProviderUser(user, 'google');
  }

  static bool isAppleOAuthUser(User user) {
    return isOAuthProviderUser(user, 'apple');
  }

  static bool isOAuthProviderUser(User user, String provider) {
    if (user.identities?.any((id) => id.provider == provider) ?? false) {
      return true;
    }
    final mainProvider = user.appMetadata['provider'] as String?;
    if (mainProvider == provider) return true;
    final providers = user.appMetadata['providers'];
    if (providers is List && providers.any((p) => p == provider)) {
      return true;
    }
    if (provider == 'google') {
      final iss = user.userMetadata?['iss'] as String? ??
          user.appMetadata['iss'] as String?;
      return iss != null && iss.contains('accounts.google.com');
    }
    return false;
  }

  Future<void> appleSignIn({
    required WidgetRef ref,
    required BuildContext context,
    required bool Function() mounted,
    required RegisterWizardFormController form,
    required Future<void> Function(User user) onOAuthConnected,
  }) async {
    FocusScope.of(context).unfocus();
    form.setError(null);

    if (!await ensureOnline(context, ref)) return;

    if (!AppConfig.hasSupabase) {
      form.setError(ShellStrings.supabaseMissingTitle);
      return;
    }

    final existingUser = ref.read(authServiceProvider).currentSession?.user;
    if (existingUser != null && isAppleOAuthUser(existingUser)) {
      await onOAuthConnected(existingUser);
      return;
    }

    form.googleLaunched = true;
    form.setGoogleSigningIn(true);

    try {
      final user =
          await ref.read(authNotifierProvider.notifier).signInWithApple();
      if (!mounted()) return;
      if (user != null) {
        await onOAuthConnected(user);
        return;
      }
      form.setError(AuthStrings.authAppleSupabaseLinkFailed);
    } on AppFailure catch (e) {
      if (!mounted()) return;
      form.setError(e.message);
    } catch (_) {
      if (!mounted()) return;
      form.setError(CoreStrings.errorUnexpected);
    } finally {
      if (mounted()) {
        form.setGoogleSigningIn(false);
        form.googleLaunched = false;
      }
    }
  }

  Future<void> recoverGoogleSessionIfNeeded({
    required WidgetRef ref,
    required RegisterWizardFormController form,
    required Future<void> Function(User user) onOAuthConnected,
  }) async {
    if (form.signedUpViaOAuth || form.step != 0) return;
    final user = ref.read(authServiceProvider).currentSession?.user;
    if (user == null) return;
    if (!form.googleSigningIn &&
        !form.googleLaunched &&
        !form.pendingGoogleSignIn &&
        !isGoogleOAuthUser(user) &&
        !isAppleOAuthUser(user)) {
      return;
    }
    await onOAuthConnected(user);
  }

  Future<void> clearStalePendingGoogleSignIn({
    required WidgetRef ref,
    required bool Function() mounted,
    required RegisterWizardFormController form,
    required Future<void> Function() tryCompletePending,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted() || form.signedUpViaOAuth) return;
    if (ref.read(authServiceProvider).currentSession?.user != null) {
      await tryCompletePending();
      return;
    }
    await form.persistDraft(pendingGoogleSignIn: false);
    if (!mounted()) return;
    form.resetGooglePending();
  }
}
