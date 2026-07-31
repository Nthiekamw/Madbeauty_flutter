import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../firebase_runtime_helpers.dart';

/// iOS : Firebase Messaging (APNs) — `permission_handler` sans macro Podfile
/// renvoie toujours « denied » et bloque le toggle.
/// Android : `permission_handler` (POST_NOTIFICATIONS).
Future<bool> arePlatformNotificationsGranted() async {
  if (Platform.isIOS) {
    return _iosNotificationsGranted();
  }
  final status = await Permission.notification.status;
  return status.isGranted;
}

Future<bool> requestPlatformNotifications() async {
  if (Platform.isIOS) {
    return _iosRequestNotifications();
  }
  final status = await Permission.notification.request();
  return status.isGranted;
}

/// True si iOS/Android a déjà refusé et qu’il faut ouvrir les Réglages.
Future<bool> arePlatformNotificationsPermanentlyDenied() async {
  if (Platform.isIOS) {
    if (!isFirebaseConfiguredForPush()) return false;
    final ready = await ensureFirebaseInitialized();
    if (!ready) return false;
    final settings =
        await FirebaseMessaging.instance.getNotificationSettings();
    // Après un refus, iOS ne réaffiche plus le dialogue système.
    return settings.authorizationStatus == AuthorizationStatus.denied;
  }
  final status = await Permission.notification.status;
  return status.isPermanentlyDenied;
}

Future<bool> _iosNotificationsGranted() async {
  if (!isFirebaseConfiguredForPush()) return false;
  final ready = await ensureFirebaseInitialized();
  if (!ready) return false;
  final settings = await FirebaseMessaging.instance.getNotificationSettings();
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<bool> _iosRequestNotifications() async {
  if (!isFirebaseConfiguredForPush()) {
    if (kDebugMode) {
      debugPrint(
        'requestPlatformNotifications(iOS): Firebase non configuré',
      );
    }
    return false;
  }
  final ready = await ensureFirebaseInitialized();
  if (!ready) return false;

  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
  );

  final granted =
      settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

  if (granted) {
    // Débloque getToken() FCM (attend le token APNs si besoin).
    try {
      await FirebaseMessaging.instance.getAPNSToken();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getAPNSToken: $e');
      }
    }
  }

  return granted;
}
