import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../services/auth/auth_service.dart';
import '../../providers/auth_notifier.dart';
import '../logic/login_validators.dart';
import '../models/auth_login_method.dart';
import '../models/login_view_state.dart';

final loginControllerProvider =
    NotifierProvider<LoginController, LoginViewState>(
  LoginController.new,
);

class LoginController extends Notifier<LoginViewState> {
  AuthService get _authService {
    if (!ref.read(authSupabaseEnabledProvider)) {
      throw StateError('AuthService indisponible sans Supabase.');
    }
    return ref.read(authServiceProvider);
  }

  @override
  LoginViewState build() => const LoginViewState();

  void setAuthMethod(AuthLoginMethod method) {
    state = state.copyWith(
      authMethod: method,
      otpCodeSent: false,
      clearEmailError: true,
      clearPasswordError: true,
      clearPhoneError: true,
      clearOtpError: true,
      clearSubmitError: true,
      requestSupabaseSnack: false,
      shouldPopRoute: false,
      isBusy: false,
    );
  }

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

  void onPhoneChanged(String _) {
    state = state.copyWith(
      clearPhoneError: true,
      clearSubmitError: true,
      requestSupabaseSnack: false,
      shouldPopRoute: false,
    );
  }

  void onOtpChanged(String _) {
    state = state.copyWith(
      clearOtpError: true,
      clearSubmitError: true,
      requestSupabaseSnack: false,
      shouldPopRoute: false,
    );
  }

  void acknowledgeSupabaseSnack() {
    state = state.copyWith(
      requestSupabaseSnack: false,
    );
  }

  void acknowledgeRouteClose() {
    state = state.copyWith(
      shouldPopRoute: false,
    );
  }

  Future<void> submit({
    required String rawEmail,
    required String rawPassword,
  }) async {
    final email = rawEmail.trim();
    final eErr = LoginValidators.email(email);
    final pErr = LoginValidators.password(rawPassword);

    if (eErr != null || pErr != null) {
      state = LoginViewState(
        emailError: eErr,
        passwordError: pErr,
        authMethod: state.authMethod,
      );
      return;
    }

    if (!AppConfig.hasSupabase) {
      state = LoginViewState(
        requestSupabaseSnack: true,
        authMethod: state.authMethod,
      );
      return;
    }

    state = LoginViewState(authMethod: state.authMethod);

    await ref.read(authNotifierProvider.notifier).signInWithPassword(
          email: email,
          password: rawPassword,
        );
    if (!ref.mounted) return;

    final auth = ref.read(authNotifierProvider);

    final User? user = switch (auth) {
      AsyncData(:final value) => value,
      _ => null,
    };

    String? submitErr;
    if (auth.hasError) {
      final err = auth.error;
      submitErr =
          err is AppFailure ? err.message : CoreStrings.errorUnexpected;
    }

    state = LoginViewState(
      submitError: submitErr,
      shouldPopRoute: user != null,
      authMethod: state.authMethod,
    );
  }

  Future<void> sendOtp({
    required String rawEmail,
    required String rawPhone,
  }) async {
    if (!AppConfig.hasSupabase) {
      state = state.copyWith(requestSupabaseSnack: true);
      return;
    }

    if (state.authMethod == AuthLoginMethod.emailOtp) {
      final email = rawEmail.trim();
      final eErr = LoginValidators.email(email);
      if (eErr != null) {
        state = LoginViewState(
          emailError: eErr,
          authMethod: state.authMethod,
        );
        return;
      }
      state = LoginViewState(
        authMethod: state.authMethod,
        isBusy: true,
      );
      try {
        await _authService.signInWithOtpEmail(
          email: email,
          emailRedirectTo: AppConfig.authEmailRedirectTo,
        );
        if (!ref.mounted) return;
        state = LoginViewState(
          authMethod: state.authMethod,
          otpCodeSent: true,
          submitError: AuthStrings.loginOtpSentEmail,
        );
      } on AppFailure catch (e) {
        if (!ref.mounted) return;
        state = LoginViewState(
          authMethod: state.authMethod,
          submitError: e.message,
        );
      } catch (e) {
        if (!ref.mounted) return;
        state = LoginViewState(
          authMethod: state.authMethod,
          submitError: CoreStrings.errorUnexpected,
        );
      }
      return;
    }

    if (state.authMethod == AuthLoginMethod.phoneOtp) {
      final phone = rawPhone.trim();
      final pErr = LoginValidators.phoneE164(phone);
      if (pErr != null) {
        state = LoginViewState(
          phoneError: pErr,
          authMethod: state.authMethod,
        );
        return;
      }
      state = LoginViewState(
        authMethod: state.authMethod,
        isBusy: true,
      );
      try {
        await _authService.signInWithOtpPhone(phone: phone);
        if (!ref.mounted) return;
        state = LoginViewState(
          authMethod: state.authMethod,
          otpCodeSent: true,
          submitError: AuthStrings.loginOtpSentSms,
        );
      } on AppFailure catch (e) {
        if (!ref.mounted) return;
        state = LoginViewState(
          authMethod: state.authMethod,
          submitError: e.message,
        );
      } catch (e) {
        if (!ref.mounted) return;
        state = LoginViewState(
          authMethod: state.authMethod,
          submitError: CoreStrings.errorUnexpected,
        );
      }
    }
  }

  Future<void> verifyOtp({
    required String rawEmail,
    required String rawPhone,
    required String rawOtp,
  }) async {
    if (!AppConfig.hasSupabase) {
      state = state.copyWith(requestSupabaseSnack: true);
      return;
    }

    final otpErr = LoginValidators.otpCode(rawOtp);
    if (otpErr != null) {
      state = LoginViewState(
        otpError: otpErr,
        authMethod: state.authMethod,
        otpCodeSent: state.otpCodeSent,
      );
      return;
    }

    final token = rawOtp.trim();
    final method = state.authMethod;
    final hadOtpSent = state.otpCodeSent;

    if (method == AuthLoginMethod.emailOtp) {
      final email = rawEmail.trim();
      final eErr = LoginValidators.email(email);
      if (eErr != null) {
        state = LoginViewState(
          emailError: eErr,
          authMethod: method,
          otpCodeSent: hadOtpSent,
        );
        return;
      }
      state = LoginViewState(
        authMethod: method,
        otpCodeSent: hadOtpSent,
      );
      await ref.read(authNotifierProvider.notifier).verifyOtpEmailSignIn(
            email: email,
            token: token,
          );
    } else {
      final phone = rawPhone.trim();
      final pErr = LoginValidators.phoneE164(phone);
      if (pErr != null) {
        state = LoginViewState(
          phoneError: pErr,
          authMethod: method,
          otpCodeSent: hadOtpSent,
        );
        return;
      }
      state = LoginViewState(
        authMethod: method,
        otpCodeSent: hadOtpSent,
      );
      await ref.read(authNotifierProvider.notifier).verifyOtpSmsSignIn(
            phone: phone,
            token: token,
          );
    }

    if (!ref.mounted) return;

    final auth = ref.read(authNotifierProvider);
    final User? user = switch (auth) {
      AsyncData(:final value) => value,
      _ => null,
    };

    String? submitErr;
    if (auth.hasError) {
      final err = auth.error;
      submitErr =
          err is AppFailure ? err.message : CoreStrings.errorUnexpected;
    }

    state = LoginViewState(
      submitError: submitErr,
      shouldPopRoute: user != null,
      authMethod: method,
      otpCodeSent: hadOtpSent,
    );
  }

  /// `true` si la fenêtre OAuth a été lancée (afficher un SnackBar d’aide côté route).
  Future<bool> startGoogleSignIn() async {
    if (!AppConfig.hasSupabase) {
      state = state.copyWith(requestSupabaseSnack: true);
      return false;
    }
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (!ref.mounted) return false;
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
