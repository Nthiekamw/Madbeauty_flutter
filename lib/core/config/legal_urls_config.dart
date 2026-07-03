/// URLs publiques (politique de confidentialité, CGU futures, etc.).
abstract final class LegalUrlsConfig {
  LegalUrlsConfig._();

  /// URL affichée dans App Store Connect et ouverte depuis l’app.
  ///
  /// Surcharge : `--dart-define=PRIVACY_POLICY_URL=https://…`
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://madbeauty-app.netlify.app/privacy.html',
  );

  /// Contact support / RGPD (en attendant support@madbeauty.app).
  static const String supportEmail = 'williamnthiekam392@gmail.com';
}
