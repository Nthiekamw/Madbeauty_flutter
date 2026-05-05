/// Configuration : `--dart-define`, ou fichier `.env` via
/// `flutter run --dart-define-from-file=.env` (voir README).
class AppConfig {
  AppConfig._();

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

  /// Mot de passe base de donnees Supabase defini dans `.env`,
  /// injecte au build avec `--dart-define-from-file=.env`.
  static const String supabaseDatabasePassword = String.fromEnvironment(
    'SUPABASE_DATABASE_PASSWORD',
    defaultValue: '',
  );

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasSupabaseDatabasePassword =>
      supabaseDatabasePassword.isNotEmpty;
}
