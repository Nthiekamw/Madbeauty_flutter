import 'login_credential_method.dart';

/// État UI du flux connexion (messages d'erreur, signaux pour la route hôte).
class LoginViewState {
  const LoginViewState({
    this.credentialMethod = LoginCredentialMethod.email,
    this.emailError,
    this.passwordError,
    this.phoneError,
    this.submitError,
    this.requestSupabaseSnack = false,
    this.shouldPopRoute = false,
    this.shouldNavigateToPhoneOtp = false,
    this.isBusy = false,
    this.infoMessage,
  });

  final LoginCredentialMethod credentialMethod;
  final String? emailError;
  final String? passwordError;
  final String? phoneError;
  final String? submitError;
  final bool requestSupabaseSnack;
  final bool shouldPopRoute;
  final bool shouldNavigateToPhoneOtp;
  final bool isBusy;
  final String? infoMessage;

  bool get isPhoneMode => credentialMethod == LoginCredentialMethod.phone;

  LoginViewState copyWith({
    LoginCredentialMethod? credentialMethod,
    String? emailError,
    String? passwordError,
    String? phoneError,
    String? submitError,
    bool? requestSupabaseSnack,
    bool? shouldPopRoute,
    bool? shouldNavigateToPhoneOtp,
    bool? isBusy,
    String? infoMessage,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearPhoneError = false,
    bool clearSubmitError = false,
    bool clearInfoMessage = false,
  }) {
    return LoginViewState(
      credentialMethod: credentialMethod ?? this.credentialMethod,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      requestSupabaseSnack: requestSupabaseSnack ?? this.requestSupabaseSnack,
      shouldPopRoute: shouldPopRoute ?? this.shouldPopRoute,
      shouldNavigateToPhoneOtp:
          shouldNavigateToPhoneOtp ?? this.shouldNavigateToPhoneOtp,
      isBusy: isBusy ?? this.isBusy,
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
    );
  }
}
