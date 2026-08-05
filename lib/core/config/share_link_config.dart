import 'app_config.dart';

/// Liens publics partagés (fiches prestataire).
class ShareLinkConfig {
  ShareLinkConfig._();

  /// Prod : `https://madbeauty.pro` (défaut) → liens courts `/@slug`.
  /// `custom` = forcer le schéma app.
  static const String httpsBaseUrl = String.fromEnvironment(
    'SHARE_BASE_URL',
    defaultValue: 'https://madbeauty.pro',
  );

  static const String customScheme = 'com.madbeauty.madbeauty';

  static const String _prestataireShareFunction = 'prestataire_share';
  static const String _reelShareFunction = 'reel_share';

  static bool get useHttpsShare {
    final v = httpsBaseUrl.trim().toLowerCase();
    return v.isNotEmpty && v != 'custom';
  }

  static String get _httpsBase =>
      httpsBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  /// Lien court brandé : `/@vichy`.
  static String prestataireHandlePath(String slug) =>
      '/@${slug.trim().toLowerCase()}';

  /// Alias technique : `/p/vichy`.
  static String prestataireSlugAliasPath(String slug) =>
      '/p/${slug.trim().toLowerCase()}';

  static String prestataireProfilePath(String prestataireId) =>
      '/prestataire/${prestataireId.trim()}';

  static String reelPath(String reelId) => '/reel/${reelId.trim()}';

  static String supabaseFunctionShareUrl(String prestataireId) {
    final base =
        '${AppConfig.supabaseUrl.replaceAll(RegExp(r'/+$'), '')}/functions/v1/$_prestataireShareFunction';
    return '$base?prestataire_id=${prestataireId.trim()}';
  }

  static String supabaseReelShareUrl(String reelId) {
    final base =
        '${AppConfig.supabaseUrl.replaceAll(RegExp(r'/+$'), '')}/functions/v1/$_reelShareFunction';
    return '$base?reel_id=${reelId.trim()}';
  }

  static String prestataireHandleHttpsUrl(String slug) {
    final base = _httpsBase;
    if (_isSupabaseFunctionBase(base)) {
      return '$base?slug=${Uri.encodeQueryComponent(slug.trim())}';
    }
    return '$base${prestataireHandlePath(slug)}';
  }

  static String prestataireProfileHttpsUrl(String prestataireId) {
    final base = _httpsBase;
    final id = prestataireId.trim();
    if (_isSupabaseFunctionBase(base)) {
      return '$base?prestataire_id=$id';
    }
    return '$base${prestataireProfilePath(id)}';
  }

  static String reelHttpsUrl(String reelId) {
    final base = _httpsBase;
    final id = reelId.trim();
    if (_isSupabaseFunctionBase(base)) {
      return ShareLinkConfig.supabaseReelShareUrl(id);
    }
    return '$base${reelPath(id)}';
  }

  static String prestataireProfileCustomUrl(String prestataireId) =>
      '$customScheme://prestataire/${prestataireId.trim()}';

  static String prestataireHandleCustomUrl(String slug) =>
      '$customScheme://@${slug.trim().toLowerCase()}';

  static String reelCustomUrl(String reelId) =>
      '$customScheme://reel/${reelId.trim()}';

  static String inviteCustomUrl(String referralCode) =>
      '$customScheme://invite/${referralCode.trim().toUpperCase()}';

  static bool _isSupabaseFunctionBase(String base) =>
      base.contains('/functions/v1/');
}
