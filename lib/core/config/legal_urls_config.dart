/// URLs publiques (politique de confidentialité, CGU, site vitrine).
abstract final class LegalUrlsConfig {
  LegalUrlsConfig._();

  /// Site vitrine (accueil, CGU, mentions légales).
  ///
  /// Surcharge : `--dart-define=WEBSITE_BASE_URL=https://…`
  static const String websiteBaseUrl = String.fromEnvironment(
    'WEBSITE_BASE_URL',
    defaultValue: 'https://madbeauty-web.netlify.app',
  );

  /// URL affichée dans App Store Connect et ouverte depuis l’app.
  ///
  /// Surcharge : `--dart-define=PRIVACY_POLICY_URL=https://…`
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://madbeauty-web.netlify.app/privacy.html',
  );

  static String get cguUrl => '$websiteBaseUrl/cgu.html';

  static String get legalNoticeUrl => '$websiteBaseUrl/mentions-legales.html';

  static String get contactUrl => '$websiteBaseUrl/contact.html';

  /// Standards de sécurité des enfants (Google Play, App Store).
  ///
  /// Surcharge : `--dart-define=CHILD_SAFETY_URL=https://…`
  static const String childSafetyUrl = String.fromEnvironment(
    'CHILD_SAFETY_URL',
    defaultValue: 'https://madbeauty-web.netlify.app/child-safety.html',
  );

  /// Contact support / RGPD (en attendant support@madbeauty.app).
  static const String supportEmail = 'williamnthiekam392@gmail.com';
}
