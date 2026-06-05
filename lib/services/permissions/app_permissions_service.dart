import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Demandes d'autorisations système (notifications, localisation).
class AppPermissionsService {
  Future<bool> areNotificationsGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

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

