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
}
