import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notification_permission_platform.dart';

/// Demandes d'autorisations système (notifications, localisation).
class AppPermissionsService {
  Future<bool> areNotificationsGranted() =>
      arePlatformNotificationsGranted();

  Future<bool> requestNotifications() => requestPlatformNotifications();

  Future<bool> areNotificationsPermanentlyDenied() =>
      arePlatformNotificationsPermanentlyDenied();

  Future<bool> isLocationGranted() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> requestLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> openSystemSettings() => openAppSettings();
}

