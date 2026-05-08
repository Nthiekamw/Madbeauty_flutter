/// État UI du flux connexion (messages d’erreur, signaux pour la route hôte).
class LoginViewState {
  const LoginViewState({
    this.emailError,
    this.passwordError,
    this.submitError,
    this.requestSupabaseSnack = false,
    this.shouldPopRoute = false,
  });

  final String? emailError;
  final String? passwordError;
  final String? submitError;
  final bool requestSupabaseSnack;
  final bool shouldPopRoute;

  LoginViewState copyWith({
    String? emailError,
    String? passwordError,
    String? submitError,
    bool? requestSupabaseSnack,
    bool? shouldPopRoute,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearSubmitError = false,
  }) {
    return LoginViewState(
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      requestSupabaseSnack: requestSupabaseSnack ?? this.requestSupabaseSnack,
      shouldPopRoute: shouldPopRoute ?? this.shouldPopRoute,
    );
  }
}
