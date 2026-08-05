import '../core/config/share_link_config.dart';
import '../core/models/domain/user/prestataire_public_slug.dart';
import '../services/auth/auth_deep_link_handler.dart';
import 'app_router.dart';
import 'prestataire_public_route.dart';

/// Parse les URI entrantes (partage, App Links, schéma custom).
abstract final class AppDeepLinks {
  AppDeepLinks._();

  static const _authHosts = {
    'login-callback',
    'subscription-return',
  };

  /// URI OAuth / confirmation e-mail / recovery (`login-callback`, etc.).
  static bool isAuthCallbackUri(Uri uri) =>
      AuthDeepLinkHandler.isAuthCallbackUri(uri);

  /// Route après retour deep link abonnement (`subscription-return`).
  static String? subscriptionReturnPath(Uri uri) {
    if (uri.host != 'subscription-return') return null;
    return AppRoutes.prestataireSubscription;
  }

  /// Chemin go_router (`/prestataire/:id`, `/@slug`, …) ou `null` si non géré.
  static String? routePathFromUri(Uri uri) {
    if (_authHosts.contains(uri.host)) return null;
    if (uri.scheme == ShareLinkConfig.customScheme) {
      return _fromCustomScheme(uri);
    }
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      return _fromHttps(uri);
    }
    return null;
  }

  static String? _fromCustomScheme(Uri uri) {
    if (uri.host == 'invite') {
      final code = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first
          : uri.path.replaceFirst('/', '');
      if (_isReferralCode(code)) {
        return '${AppRoutes.clientReferral}?code=$code';
      }
    }
    if (uri.host == 'prestataire') {
      final id = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first
          : uri.path.replaceFirst('/', '');
      if (isPublicPrestataireId(id)) {
        return '${AppRoutes.prestatairePublicProfile}/$id';
      }
      final slug = PrestatairePublicSlug.normalize(id);
      if (slug != null) return '/@$slug';
    }
    // com.madbeauty.madbeauty://@vichy  → host peut être vide / path @vichy
    if (uri.host.startsWith('@')) {
      final slug = PrestatairePublicSlug.normalize(uri.host);
      if (slug != null) return '/@$slug';
    }
    if (uri.host == 'reel') {
      final id = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first
          : uri.path.replaceFirst('/', '');
      if (isPublicPrestataireId(id)) {
        return '${AppRoutes.clientReel}?reelId=$id';
      }
    }
    if (uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'prestataire') {
      final id = uri.pathSegments[1];
      if (isPublicPrestataireId(id)) {
        return '${AppRoutes.prestatairePublicProfile}/$id';
      }
    }
    if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'reel') {
      final id = uri.pathSegments[1];
      if (isPublicPrestataireId(id)) {
        return '${AppRoutes.clientReel}?reelId=$id';
      }
    }
    if (uri.pathSegments.isNotEmpty) {
      final first = uri.pathSegments.first;
      final slug = PrestatairePublicSlug.normalize(first);
      if (slug != null && first.startsWith('@')) return '/@$slug';
      if (uri.pathSegments.length >= 2 &&
          uri.pathSegments.first == 'p') {
        final slug2 = PrestatairePublicSlug.normalize(uri.pathSegments[1]);
        if (slug2 != null) return '/@$slug2';
      }
    }
    return null;
  }

  static String? _fromHttps(Uri uri) {
    final queryId = uri.queryParameters['prestataire_id'];
    if (isPublicPrestataireId(queryId)) {
      return '${AppRoutes.prestatairePublicProfile}/$queryId';
    }

    final querySlug = PrestatairePublicSlug.normalize(
      uri.queryParameters['slug'],
    );
    if (querySlug != null) return '/@$querySlug';

    final reelId = uri.queryParameters['reel_id'];
    if (isPublicPrestataireId(reelId)) {
      return '${AppRoutes.clientReel}?reelId=$reelId';
    }

    final segments = uri.pathSegments;
    if (segments.isNotEmpty) {
      final first = segments.first;
      // /@vichy
      final handle = PrestatairePublicSlug.normalize(first);
      if (handle != null && (first.startsWith('@') || uri.path.startsWith('/@'))) {
        return '/@$handle';
      }
      // path "/@vichy" sometimes yields segment "@vichy"
      if (first.startsWith('@')) {
        final s = PrestatairePublicSlug.normalize(first);
        if (s != null) return '/@$s';
      }
    }
    if (segments.length >= 2 &&
        segments[0] == 'p') {
      final slug = PrestatairePublicSlug.normalize(segments[1]);
      if (slug != null) return '/@$slug';
    }
    if (segments.length >= 2 &&
        segments[0] == 'prestataire' &&
        isPublicPrestataireId(segments[1])) {
      return '/prestataire/${segments[1]}';
    }
    if (segments.length >= 2 &&
        segments[0] == 'reel' &&
        isPublicPrestataireId(segments[1])) {
      return '${AppRoutes.clientReel}?reelId=${segments[1]}';
    }
    return null;
  }

  /// Redirige `/prestataires/:id` (ancien chemin) vers `/prestataire/:id`.
  static bool _isReferralCode(String? value) {
    final v = value?.trim().toUpperCase() ?? '';
    return RegExp(r'^MB[0-9A-F]{6}$').hasMatch(v);
  }

  static String? legacyListingRedirect(String location) {
    const prefix = '${AppRoutes.prestatairesLegacy}/';
    if (!location.startsWith(prefix)) return null;
    final id = location.substring(prefix.length).split('/').first;
    if (!isPublicPrestataireId(id)) return null;
    return '${AppRoutes.prestatairePublicProfile}/$id';
  }
}
