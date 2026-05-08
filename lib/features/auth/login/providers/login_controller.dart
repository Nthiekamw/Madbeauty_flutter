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
      );
      return;
    }

    if (!AppConfig.hasSupabase) {
      state = const LoginViewState(
        requestSupabaseSnack: true,
      );
      return;
    }

    state = const LoginViewState();

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
          err is AppFailure ? err.message : AppStrings.errorUnexpected;
    }

    state = LoginViewState(
      submitError: submitErr,
      shouldPopRoute: user != null,
    );
  }
}
