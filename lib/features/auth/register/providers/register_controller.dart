import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../providers/auth_notifier.dart';
import '../logic/register_validators.dart';
import '../models/register_view_state.dart';

final registerControllerProvider =
    NotifierProvider<RegisterController, RegisterViewState>(
  RegisterController.new,
);

class RegisterController extends Notifier<RegisterViewState> {
  @override
  RegisterViewState build() => const RegisterViewState();

  void onNameChanged(String _) {
    state = state.copyWith(
      clearNameError: true,
      clearSubmitError: true,
      requestSupabaseSnack: false,
      shouldPopRoute: false,
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

  void acknowledgeSupabaseSnack() {
    state = state.copyWith(requestSupabaseSnack: false);
  }

  void acknowledgeRouteClose() {
    state = state.copyWith(shouldPopRoute: false);
  }

  Future<void> submit({
    required String rawName,
    required String rawEmail,
    required String rawPassword,
  }) async {
    final name = rawName.trim();
    final email = rawEmail.trim();
    final nameErr = RegisterValidators.name(name);
    final emailErr = RegisterValidators.email(email);
    final passwordErr = RegisterValidators.password(rawPassword);

    if (nameErr != null || emailErr != null || passwordErr != null) {
      state = RegisterViewState(
        nameError: nameErr,
        emailError: emailErr,
        passwordError: passwordErr,
      );
      return;
    }

    if (!AppConfig.hasSupabase) {
      state = const RegisterViewState(requestSupabaseSnack: true);
      return;
    }

    state = const RegisterViewState();

    await ref.read(authNotifierProvider.notifier).signUpWithPassword(
          email: email,
          password: rawPassword,
          displayName: name,
        );
    if (!ref.mounted) return;

    final auth = ref.read(authNotifierProvider);
    final User? user = switch (auth) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final hasActiveSession =
        ref.read(authServiceProvider).currentSession?.user != null;

    String? submitErr;
    if (auth.hasError) {
      final err = auth.error;
      submitErr =
          err is AppFailure ? err.message : CoreStrings.errorUnexpected;
    }

    state = RegisterViewState(
      submitError: submitErr,
      shouldPopRoute: user != null && hasActiveSession,
    );
  }
}
