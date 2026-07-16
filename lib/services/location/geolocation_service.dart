import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class ClientLocation {
  const ClientLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class GeolocationService {
  /// Sur le web, [Geolocator.checkPermission] renvoie souvent `denied` même
  /// quand [getCurrentPosition] peut encore obtenir la position (prompt
  /// navigateur). On ne bloque donc pas uniquement sur le statut permission.
  Future<ClientLocation?> getCurrentLocation() async {
    try {
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return null;

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      } else {
        // Déclenche le prompt navigateur si besoin (no-op si déjà décidé).
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          await Geolocator.requestPermission();
        }
      }

      return await _readPosition();
    } on Exception {
      return null;
    }
  }

  /// Position actuelle uniquement si la permission est déjà accordée (pas de popup).
  Future<ClientLocation?> getCurrentLocationIfPermitted() async {
    try {
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return null;
      }

      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        // Sur web, checkPermission est peu fiable : on ne tente pas
        // getCurrentPosition ici pour éviter un prompt au démarrage.
        return null;
      }

      return await _readPosition(timeLimit: const Duration(seconds: 5));
    } on Exception {
      return null;
    }
  }

  Future<ClientLocation?> _readPosition({Duration? timeLimit}) async {
    final LocationSettings settings;
    if (kIsWeb) {
      settings = WebSettings(
        accuracy: LocationAccuracy.medium,
        maximumAge: const Duration(minutes: 2),
        timeLimit: timeLimit,
      );
    } else {
      settings = LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: timeLimit,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: settings,
    );

    return ClientLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
