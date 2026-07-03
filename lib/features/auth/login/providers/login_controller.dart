import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../providers/auth_notifier.dart';
import '../logic/login_validators.dart';
import '../models/login_view_state.dart';

final loginControllerProvider =
    NotifierProvider<LoginController, LoginViewState>(
  LoginController.new,
);

class LoginController extends Notifier<LoginViewState> {
  static const _retryCooldown = Duration(seconds: 2);
  DateTime? _nextAllowedSubmitAt;

  @override
  LoginViewState build() => const LoginViewState();

  void onEmailChanged(String _) {
    state = state.copyWith(
      clearEmailError: true,
      clearSubmitError: true,
      requestSupabaseSnack: false,
      shouldPopRoute: false,
    );
  }

  void onPasswordChanged(String _) {
    state = state.copyWith(
      clearPasswordError: true,
      clearSubmitError: true,
      requestSupabaseSnack: false,
      shouldPopRoute: false,
    );
  }

  void acknowledgeSupabaseSnack() {
    state = state.copyWith(requestSupabaseSnack: false);
  }

  void acknowledgeRouteClose() {
    state = state.copyWith(shouldPopRoute: false);
  }

  void acknowledgeSubmitError() {
    state = state.copyWith(clearSubmitError: true);
  }

  Future<void> submit({
    required String rawEmail,
    required String rawPassword,
  }) async {
    final now = DateTime.now();
    final nextAllowed = _nextAllowedSubmitAt;
    if (nextAllowed != null && now.isBefore(nextAllowed)) {
      state = state.copyWith(submitError: AuthStrings.loginRetryCooldown);
      return;
    }

    final email = rawEmail.trim();
    final eErr = LoginValidators.email(email);
    final pErr = LoginValidators.password(rawPassword);

    if (eErr != null || pErr != null) {
      state = LoginViewState(
        emailError: eErr,
        passwordError: pErr,
      );
      return;
    }

    if (!AppConfig.hasSupabase) {
      state = const LoginViewState(requestSupabaseSnack: true);
      return;
    }

    state = const LoginViewState(isBusy: true);

    User? signedInUser;
    try {
      signedInUser = await ref.read(authNotifierProvider.notifier).signInWithPassword(
            email: email,
            password: rawPassword,
          );
    } on AppFailure catch (e) {
      if (!ref.mounted) return;
      _nextAllowedSubmitAt = DateTime.now().add(_retryCooldown);
      state = LoginViewState(
        submitError: e.message,
        isBusy: false,
      );
      return;
    } catch (_) {
      if (!ref.mounted) return;
      _nextAllowedSubmitAt = DateTime.now().add(_retryCooldown);
      state = const LoginViewState(
        submitError: CoreStrings.errorUnexpected,
        isBusy: false,
      );
      return;
    }
    if (!ref.mounted) return;

    final auth = ref.read(authNotifierProvider);
    final user = signedInUser ??
        switch (auth) {
          AsyncData(:final value) => value,
          _ => null,
        };

    String? submitErr;
    if (auth.hasError) {
      final err = auth.error;
      submitErr =
          err is AppFailure ? err.message : CoreStrings.errorUnexpected;
      _nextAllowedSubmitAt = DateTime.now().add(_retryCooldown);
    }

    state = LoginViewState(
      submitError: submitErr,
      shouldPopRoute: user != null,
      isBusy: false,
    );
  }

  /// `true` si la fenêtre OAuth a été lancée (afficher un SnackBar d'aide côté route).
  Future<bool> startGoogleSignIn() async {
    if (!AppConfig.hasSupabase) {
      state = state.copyWith(requestSupabaseSnack: true);
      return false;
    }
    try {
      final user =
          await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (!ref.mounted) return false;
      if (user != null) {
        state = state.copyWith(
          shouldPopRoute: true,
          clearSubmitError: true,
        );
        return true;
      }
      state = state.copyWith(clearSubmitError: true);
      return true;
    } on AppFailure catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(submitError: e.message);
      return false;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(submitError: CoreStrings.errorUnexpected);
      return false;
    }
  }

  Future<bool> startAppleSignIn() async {
    if (!AppConfig.hasSupabase) {
      state = state.copyWith(requestSupabaseSnack: true);
      return false;
    }
    try {
      final user =
          await ref.read(authNotifierProvider.notifier).signInWithApple();
      if (!ref.mounted) return false;
      if (user != null) {
        state = state.copyWith(
          shouldPopRoute: true,
          clearSubmitError: true,
        );
        return true;
      }
      state = state.copyWith(clearSubmitError: true);
      return true;
    } on AppFailure catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(submitError: e.message);
      return false;
    } catch (_) {
      if (!ref.mounted) return false;
      state = state.copyWith(submitError: CoreStrings.errorUnexpected);
      return false;
    }
  }
}
