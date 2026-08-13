// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:firebase_messaging/firebase_messaging.dart';

/// iOS Safari : le Notifications API n'est disponible que si la PWA est
/// installée sur l'écran d'accueil (mode standalone), sinon `requestPermission`
/// échoue silencieusement (reste `default`) même sur iOS 16.4+.
bool isIosPwaNotInstalled() {
  final ua = html.window.navigator.userAgent.toLowerCase();
  final isAppleMobile =
      ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
  if (!isAppleMobile) return false;

  final displayModeStandalone =
      html.window.matchMedia('(display-mode: standalone)').matches;
  final navigatorStandalone =
      js_util.getProperty(html.window.navigator, 'standalone') == true;

  return !displayModeStandalone && !navigatorStandalone;
}

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
