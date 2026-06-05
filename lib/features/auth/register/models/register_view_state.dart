class RegisterViewState {
  const RegisterViewState({
    this.nameError,
    this.emailError,
    this.passwordError,
    this.submitError,
    this.requestSupabaseSnack = false,
    this.shouldPopRoute = false,
  });

  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? submitError;
  final bool requestSupabaseSnack;
  final bool shouldPopRoute;

  RegisterViewState copyWith({
    String? nameError,
    String? emailError,
    String? passwordError,
    String? submitError,
    bool? requestSupabaseSnack,
    bool? shouldPopRoute,
    bool clearNameError = false,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearSubmitError = false,
  }) {
    return RegisterViewState(
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError:
          clearPasswordError ? null : (passwordError ?? this.passwordError),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      requestSupabaseSnack: requestSupabaseSnack ?? this.requestSupabaseSnack,
      shouldPopRoute: shouldPopRoute ?? this.shouldPopRoute,
    );
  }
}

