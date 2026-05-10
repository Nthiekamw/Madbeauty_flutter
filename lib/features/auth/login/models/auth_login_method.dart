/// Mode de connexion proposé sur l’écran login.
enum AuthLoginMethod {
  /// E-mail + mot de passe.
  password,

  /// Code à usage unique envoyé par e-mail (template Supabase avec `{{ .Token }}`).
  emailOtp,

  /// Code SMS (téléphone au format E.164, ex. +33612345678).
  phoneOtp,
}
