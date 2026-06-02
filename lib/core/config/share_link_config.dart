import 'app_config.dart';

/// Liens publics partagés (fiches prestataire).
class ShareLinkConfig {
  ShareLinkConfig._();

  /// Vide = auto Supabase si configuré, sinon schéma custom.
  /// `custom` = forcer le schéma app.
  /// `https://ton-site.com` = futur format `/prestataire/:id`.
  static const String httpsBaseUrl = String.fromEnvironment(
    'SHARE_BASE_URL',
    defaultValue: '',
  );

  static const String customScheme = 'com.madbeauty.madbeauty';

  static const String _prestataireShareFunction = 'prestataire_share';

  static bool get useHttpsShare {
    final v = httpsBaseUrl.trim().toLowerCase();
    return v.isNotEmpty && v != 'custom';
  }

  static String prestataireProfilePath(String prestataireId) =>
      '/prestataire/${prestataireId.trim()}';

  static String supabaseFunctionShareUrl(String prestataireId) {
    final base =
        '${AppConfig.supabaseUrl.replaceAll(RegExp(r'/+$'), '')}/functions/v1/$_prestataireShareFunction';
    return '$base?prestataire_id=${prestataireId.trim()}';
  }

  static String prestataireProfileHttpsUrl(String prestataireId) {
    final base = httpsBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final id = prestataireId.trim();
    if (_isSupabaseFunctionBase(base)) {
      return '$base?prestataire_id=$id';
    }
    return '$base${prestataireProfilePath(id)}';
  }

  static String prestataireProfileCustomUrl(String prestataireId) =>
      '$customScheme://prestataire/${prestataireId.trim()}';

  static String inviteCustomUrl(String referralCode) =>
      '$customScheme://invite/${referralCode.trim().toUpperCase()}';

  static bool _isSupabaseFunctionBase(String base) =>
      base.contains('/functions/v1/');
}
