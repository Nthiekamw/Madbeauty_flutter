/// Contexte d’utilisation de la vérification OTP téléphone.
enum PhoneOtpFlow {
  login,
  register,
}

extension PhoneOtpFlowX on PhoneOtpFlow {
  String get queryValue => name;

  static PhoneOtpFlow? fromQuery(String? raw) => switch (raw) {
        'login' => PhoneOtpFlow.login,
        'register' => PhoneOtpFlow.register,
        _ => null,
      };
}
