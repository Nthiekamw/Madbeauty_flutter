import 'package:flutter/foundation.dart';

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

  /// URL de retour OAuth Google sur Flutter Web (doit être autorisée dans Supabase).
  /// Ex. `http://localhost:7357` en dev (`scripts/run_flutter_web.ps1`).
  static const String supabaseWebRedirectUrl = String.fromEnvironment(
    'SUPABASE_WEB_REDIRECT_URL',
    defaultValue: '',
  );

  static bool get hasSupabase =>
      debugSupabaseEnabledOverride ??
      (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty);

  static bool _isValidHttpOrigin(String origin) =>
      origin.isNotEmpty &&
      origin != 'null' &&
      (origin.startsWith('http://') || origin.startsWith('https://'));

  static bool _isLocalHostUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('localhost') || lower.contains('127.0.0.1');
  }

  /// Origine HTTP(S) de retour auth sur Flutter Web (OAuth, e-mails).
  ///
  /// Sur un site déployé (Netlify, etc.) : toujours [Uri.base.origin].
  /// En dev local : origine courante ou [supabaseWebRedirectUrl].
  ///
  /// À autoriser dans Supabase → Auth → URL Configuration → Redirect URLs.
  static String? get authWebRedirectTo {
    final configured = supabaseWebRedirectUrl.trim();
    final origin = Uri.base.origin;
    final originValid = _isValidHttpOrigin(origin);

    // Prod / preview : ne jamais renvoyer vers localhost compilé depuis .env dev.
    if (originValid && !_isLocalHostUrl(origin)) return origin;

    if (!kReleaseMode && originValid) return origin;

    if (configured.isNotEmpty && !_isLocalHostUrl(configured)) return configured;
    if (configured.isNotEmpty) return configured;

    if (originValid) return origin;
    return null;
  }

  /// Deep link de retour e-mail (confirmation, mot de passe oublié).
  /// Web : origine HTTP(S). Mobile : deep link app.
  static String? get authEmailRedirectTo {
    if (kIsWeb) return authWebRedirectTo;

    final configured = supabaseEmailRedirectUrl.trim();
    if (configured.isNotEmpty) return configured;
    if (hasSupabase) {
      return '${ShareLinkConfig.customScheme}://login-callback';
    }
    return null;
  }

  /// URL de redirection OAuth (Google) : origine web ou deep link mobile.
  static String? get authOAuthRedirectTo {
    if (kIsWeb) return authWebRedirectTo;
    return authEmailRedirectTo;
  }
}

