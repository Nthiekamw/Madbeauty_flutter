import 'package:permission_handler/permission_handler.dart';

Future<bool> arePlatformNotificationsGranted() async {
  final status = await Permission.notification.status;
  return status.isGranted;
}

Future<bool> requestPlatformNotifications() async {
  final status = await Permission.notification.request();
  return status.isGranted;
}
