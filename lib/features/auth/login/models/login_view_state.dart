import 'auth_login_method.dart';

/// État UI du flux connexion (messages d’erreur, signaux pour la route hôte).
class LoginViewState {
  const LoginViewState({
    this.emailError,
    this.passwordError,
    this.phoneError,
    this.otpError,
    this.submitError,
    this.requestSupabaseSnack = false,
    this.shouldPopRoute = false,
    this.authMethod = AuthLoginMethod.password,
    this.otpCodeSent = false,
    this.isBusy = false,
  });

  final String? emailError;
  final String? passwordError;
  final String? phoneError;
  final String? otpError;
  final String? submitError;
  final bool requestSupabaseSnack;
  final bool shouldPopRoute;
  final AuthLoginMethod authMethod;
  final bool otpCodeSent;
  final bool isBusy;

  LoginViewState copyWith({
    String? emailError,
    String? passwordError,
    String? phoneError,
    String? otpError,
    String? submitError,
    bool? requestSupabaseSnack,
    bool? shouldPopRoute,
    AuthLoginMethod? authMethod,
    bool? otpCodeSent,
    bool? isBusy,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearPhoneError = false,
    bool clearOtpError = false,
    bool clearSubmitError = false,
  }) {
    return LoginViewState(
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      requestSupabaseSnack: requestSupabaseSnack ?? this.requestSupabaseSnack,
      shouldPopRoute: shouldPopRoute ?? this.shouldPopRoute,
      authMethod: authMethod ?? this.authMethod,
      otpCodeSent: otpCodeSent ?? this.otpCodeSent,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}
