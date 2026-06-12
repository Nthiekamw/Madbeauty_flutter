import 'share_link_config.dart';

/// Configuration : `--dart-define`, ou fichier `.env` via
/// `flutter run --dart-define-from-file=.env` (voir README).
class AppConfig {
  AppConfig._();

  /// Délai max des requêtes Supabase (REST, Auth, Storage, Edge Functions).
  static const Duration supabaseHttpTimeout = Duration(seconds: 10);

  /// Délai max des connexions / événements Realtime.
  static const Duration supabaseRealtimeTimeout = Duration(seconds: 10);

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

  static bool get hasSupabase =>
      debugSupabaseEnabledOverride ??
      (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty);

  /// Deep link de retour e-mail (confirmation, mot de passe oublié).
  /// Fallback sur le schéma app si `.env` non renseigné.
  static String? get authEmailRedirectTo {
    final configured = supabaseEmailRedirectUrl.trim();
    if (configured.isNotEmpty) return configured;
    if (hasSupabase) {
      return '${ShareLinkConfig.customScheme}://login-callback';
    }
    return null;
  }
}

