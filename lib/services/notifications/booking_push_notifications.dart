import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../firebase_options.dart';
import '../../firebase_runtime_helpers.dart';
import '../supabase/profile/profile_service.dart';
import '../storage/local_cache_service.dart';

/// Canal Android pour les notifications locales (premier plan).
const String madBeautyBookingAndroidChannelId = 'madbeauty_booking_channel';

/// Firebase + FCM + notifications locales (demandes de réservation, statuts).
class BookingPushNotifications {
  BookingPushNotifications._();

  static final BookingPushNotifications instance = BookingPushNotifications._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _onTokenRefresh;
  String? _activeUserId;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onOpenedAppSub;
  bool _localNotificationsReady = false;
  bool _inboxOpenedAppAttached = false;
  void Function(RemoteMessage)? _onInboxMessage;
  void Function(RemoteMessage)? _onNotificationOpened;

  bool get isConfigured => isFirebaseConfiguredForPush();

  void setOnInboxMessage(void Function(RemoteMessage)? handler) {
    _onInboxMessage = handler;
  }

  void setOnNotificationOpened(void Function(RemoteMessage)? handler) {
    _onNotificationOpened = handler;
  }

  void _deliverToInbox(RemoteMessage message) {
    final n = message.notification;
    var body = n?.body ?? (message.data['body'] as String?) ?? '';
    body = body.trim();
    if (body.isEmpty) return;
    _onInboxMessage?.call(message);
  }

  void _deliverOpened(RemoteMessage message) {
    _deliverToInbox(message);
    _onNotificationOpened?.call(message);
  }

  Future<void> _attachOpenedAppInboxDelivery() async {
    if (_inboxOpenedAppAttached) return;
    _inboxOpenedAppAttached = true;
    await _onOpenedAppSub?.cancel();
    _onOpenedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_deliverOpened);
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _deliverOpened(initial);
  }

  Future<void> syncForUser({
    required String? userId,
    required ProfileService? profileService,
  }) async {
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint(
          'BookingPushNotifications: Firebase non configuré — exécuter '
          '`dart run flutterfire_cli:flutterfire configure`.',
        );
      }
      return;
    }

    if (userId == null) {
      await _signOutCleanup(profileService: profileService);
      return;
    }

    if (_activeUserId == userId) {
      await _ensureTokenSynced(profileService: profileService, userId: userId);
      return;
    }

    await _disposeListeners();

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('BookingPushNotifications: init Firebase — $e\n$st');
      }
      return;
    }

    _activeUserId = userId;

    await _initializeLocalNotifications();
    await _requestPermissionsFirstLaunch();
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _onTokenRefresh = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) => _persistToken(profileService: profileService, token: token),
    );

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((message) async {
      await _onForegroundMessage(message);
      _deliverToInbox(message);
    });

    await _attachOpenedAppInboxDelivery();

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await _persistToken(profileService: profileService, token: token);
    }
  }

  Future<void> _signOutCleanup({required ProfileService? profileService}) async {
    final prev = _activeUserId;
    await _disposeListeners();
    _activeUserId = null;

    if (prev != null && profileService != null) {
      try {
        await profileService.clearFcmToken(userId: prev);
      } catch (_) {
        /* best-effort */
      }
    }

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      /* best-effort */
    }
  }

  Future<void> _disposeListeners() async {
    await _onMessageSubscription?.cancel();
    _onMessageSubscription = null;
    await _onTokenRefresh?.cancel();
    _onTokenRefresh = null;
    await _onOpenedAppSub?.cancel();
    _onOpenedAppSub = null;
    _inboxOpenedAppAttached = false;
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsReady) return;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    await _local.initialize(const InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    ));

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        madBeautyBookingAndroidChannelId,
        'MadBeauty — réservations',
        description: 'Demandes et statuts de réservation.',
        importance: Importance.high,
      );
      final androidImplementation = _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(channel);
    }

    _localNotificationsReady = true;
  }

  /// Dialogue système uniquement lors du premier flux (persisté localement).
  Future<void> _requestPermissionsFirstLaunch() async {
    final cache = LocalCacheService.instance;

    if (cache.pushPermissionPrompted) return;

    if (Platform.isAndroid) {
      await Permission.notification.request();
    } else if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await cache.setPushPermissionPrompted();
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      final androidDetails = AndroidNotificationDetails(
        madBeautyBookingAndroidChannelId,
        'MadBeauty — réservations',
        channelDescription: 'Demandes et statuts de réservation.',
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails();

      await _local.show(
        notification.hashCode,
        notification.title ?? 'MadBeauty',
        notification.body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
      );
    }
  }

  Future<void> _persistToken({
    required ProfileService? profileService,
    required String token,
  }) async {
    final uid = _activeUserId;
    if (uid == null || profileService == null) return;
    try {
      await profileService.upsertFcmToken(userId: uid, token: token);
    } catch (_) {
      /* Hors ligne ou erreur réseau */
    }
  }

  Future<void> _ensureTokenSynced({
    required ProfileService? profileService,
    required String userId,
  }) async {
    if (!isConfigured || Firebase.apps.isEmpty) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await profileService?.upsertFcmToken(userId: userId, token: token);
      }
    } catch (_) {}
  }
}
