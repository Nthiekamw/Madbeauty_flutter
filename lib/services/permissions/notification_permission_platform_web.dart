// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'package:firebase_messaging/firebase_messaging.dart';

Future<bool> arePlatformNotificationsGranted() async {
  if (!html.Notification.supported) return false;
  return html.Notification.permission == 'granted';
}

Future<bool> requestPlatformNotifications() async {
  if (!html.Notification.supported) return false;

  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<bool> arePlatformNotificationsPermanentlyDenied() async {
  if (!html.Notification.supported) return true;
  return html.Notification.permission == 'denied';
}
