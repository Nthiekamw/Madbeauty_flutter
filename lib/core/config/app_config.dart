/// Configuration : `--dart-define`, ou fichier `.env` via
/// `flutter run --dart-define-from-file=.env` (voir README).
class AppConfig {
  AppConfig._();

  static bool? debugSupabaseEnabledOverride;

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// URL de redirection pour les e-mails Supabase (confirmation, recovery).
  /// Exemple mobile (deep link): com.madbeauty.madbeauty://login-callback
  static const String supabaseEmailRedirectUrl = String.fromEnvironment(
    'SUPABASE_EMAIL_REDIRECT_URL',
    defaultValue: '',
  );

  /// Mot de passe base de donnees Supabase defini dans `.env`,
  /// injecte au build avec `--dart-define-from-file=.env`.
  static const String supabaseDatabasePassword = String.fromEnvironment(
    'SUPABASE_DATABASE_PASSWORD',
    defaultValue: '',
  );

  static bool get hasSupabase =>
      debugSupabaseEnabledOverride ??
      (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty);

  static bool get hasSupabaseDatabasePassword =>
      supabaseDatabasePassword.isNotEmpty;

  static String? get authEmailRedirectTo =>
      supabaseEmailRedirectUrl.isEmpty ? null : supabaseEmailRedirectUrl;
}
