import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre l’app / site de cartographie pour un itinéraire vers une destination.
abstract final class MapsDirectionsLauncher {
  MapsDirectionsLauncher._();

  /// Construit l’URI (testable). Préfère Apple Maps sur iOS, Google sinon.
  static Uri buildDirectionsUri({
    required double destLat,
    required double destLng,
    String? destLabel,
    double? originLat,
    double? originLng,
  }) {
    final useApple = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    if (useApple) {
      final params = <String, String>{
        'daddr': '$destLat,$destLng',
        'dirflg': 'd',
      };
      if (originLat != null && originLng != null) {
        params['saddr'] = '$originLat,$originLng';
      }
      if (destLabel != null && destLabel.trim().isNotEmpty) {
        params['q'] = destLabel.trim();
      }
      return Uri.https('maps.apple.com', '/', params);
    }

    final params = <String, String>{
      'api': '1',
      'destination': '$destLat,$destLng',
      'travelmode': 'driving',
    };
    if (originLat != null && originLng != null) {
      params['origin'] = '$originLat,$originLng';
    }
    return Uri.https('www.google.com', '/maps/dir/', params);
  }

  /// `true` si une appli / un navigateur a pu ouvrir l’itinéraire.
  static Future<bool> openDirections({
    required double destLat,
    required double destLng,
    String? destLabel,
    double? originLat,
    double? originLng,
  }) async {
    final uri = buildDirectionsUri(
      destLat: destLat,
      destLng: destLng,
      destLabel: destLabel,
      originLat: originLat,
      originLng: originLng,
    );
    const modes = [
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
      LaunchMode.inAppBrowserView,
    ];
    for (final mode in modes) {
      try {
        if (await launchUrl(uri, mode: mode)) return true;
      } catch (_) {}
    }
    return false;
  }
}
