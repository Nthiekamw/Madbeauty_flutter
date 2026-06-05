import '../core/config/share_link_config.dart';
import 'app_router.dart';
import 'prestataire_public_route.dart';

/// Parse les URI entrantes (partage, App Links, schéma custom).
abstract final class AppDeepLinks {
  AppDeepLinks._();

  static const _authHosts = {
    'login-callback',
    'stripe-connect-return',
    'stripe-connect-refresh',
    'subscription-return',
    'client-payment-return',
  };

  /// Route après retour Stripe Checkout abonnement (`subscription-return`).
  static String? subscriptionReturnPath(Uri uri) {
    if (uri.host != 'subscription-return') return null;
    return AppRoutes.prestataireSubscription;
  }

  /// Route après portail Stripe client (`client-payment-return`).
  static String? clientPaymentReturnPath(Uri uri) {
    if (uri.host != 'client-payment-return') return null;
    return AppRoutes.clientPaymentMethods;
  }

  /// Chemin go_router (`/prestataire/:id`) ou `null` si non géré ici.
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
    }
    if (uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'prestataire') {
      final id = uri.pathSegments[1];
      if (isPublicPrestataireId(id)) {
        return '${AppRoutes.prestatairePublicProfile}/$id';
      }
    }
    return null;
  }

  static String? _fromHttps(Uri uri) {
    final queryId = uri.queryParameters['prestataire_id'];
    if (isPublicPrestataireId(queryId)) {
      return '${AppRoutes.prestatairePublicProfile}/$queryId';
    }

    final segments = uri.pathSegments;
    if (segments.length >= 2 &&
        segments[0] == 'prestataire' &&
        isPublicPrestataireId(segments[1])) {
      return '/prestataire/${segments[1]}';
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
