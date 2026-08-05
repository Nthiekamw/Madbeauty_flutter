import 'package:flutter/foundation.dart';

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

  /// Lien App Store MadBeauty (partage iOS).
  static const String appStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue: 'https://apps.apple.com/app/id6786782749',
  );

  /// Lien Play Store (vide tant que l’app Android n’est pas publiée).
  static const String playStoreUrl = String.fromEnvironment(
    'PLAY_STORE_URL',
    defaultValue: '',
  );

  static const String _prestataireShareFunction = 'prestataire_share';
  static const String _reelShareFunction = 'reel_share';

  static bool get useHttpsShare {
    final v = httpsBaseUrl.trim().toLowerCase();
    return v.isNotEmpty && v != 'custom';
  }

  static String get _httpsBase =>
      httpsBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  static String get _webFallback =>
      _httpsBase.isEmpty ? 'https://madbeauty.pro' : _httpsBase;

  /// Lien « télécharger / découvrir MadBeauty » selon la plateforme courante.
  ///
  /// - Web → [httpsBaseUrl] (`madbeauty.pro`)
  /// - iOS → App Store
  /// - Android → Play Store si défini, sinon `madbeauty.pro`
  static String downloadUrlForCurrentPlatform() {
    if (kIsWeb) return _webFallback;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        final apple = appStoreUrl.trim();
        return apple.isNotEmpty ? apple : _webFallback;
      case TargetPlatform.android:
        final play = playStoreUrl.trim();
        return play.isNotEmpty ? play : _webFallback;
      default:
        return _webFallback;
    }
  }

  /// Ligne à ajouter sous le lien partagé (téléchargement / site).
  static String? downloadShareFooter({required String hint}) {
    final url = downloadUrlForCurrentPlatform().trim();
    if (url.isEmpty) return null;
    return '$hint\n$url';
  }

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
