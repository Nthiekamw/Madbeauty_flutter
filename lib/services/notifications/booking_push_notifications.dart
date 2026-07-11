import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/config/app_config.dart';
import '../../firebase_options.dart';
import '../../firebase_runtime_helpers.dart';
import '../permissions/notification_permission_platform.dart';
import '../supabase/profile/profile_service.dart';
import '../storage/local_cache_service.dart';
import 'web_browser_notification.dart';

/// Canal Android pour les notifications locales (premier plan).
const String madBeautyBookingAndroidChannelId = 'madbeauty_booking_channel';
const String madBeautyMessagingAndroidChannelId = 'madbeauty_messaging_channel';

bool _isAndroidNative() =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool _isIosNative() => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

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
  static bool _loggedPushUnavailable = false;
  void Function(RemoteMessage)? _onInboxMessage;
  void Function(RemoteMessage)? _onNotificationOpened;
  void Function(Map<String, dynamic>)? _onPushDataOpened;

  bool get isConfigured => isFirebaseConfiguredForPush();

  void setOnInboxMessage(void Function(RemoteMessage)? handler) {
    _onInboxMessage = handler;
  }

  void setOnNotificationOpened(void Function(RemoteMessage)? handler) {
    _onNotificationOpened = handler;
  }

  void setOnPushDataOpened(void Function(Map<String, dynamic>)? handler) {
    _onPushDataOpened = handler;
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
      if (kDebugMode && !_loggedPushUnavailable) {
        _loggedPushUnavailable = true;
        final hint = kIsWeb
            ? 'Web Push désactivé — définir FIREBASE_WEB_VAPID_KEY dans .env '
                '(Firebase → Cloud Messaging → certificats Web).'
            : 'Firebase non configuré – exécuter '
                '`dart run flutterfire_cli:flutterfire configure`.';
        debugPrint('BookingPushNotifications: $hint');
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
        debugPrint('BookingPushNotifications: init Firebase – $e\n$st');
      }
      return;
    }

    _activeUserId = userId;

    if (!kIsWeb) {
      await _initializeLocalNotifications();
    }
    unawaited(_requestPermissionsFirstLaunch());
    if (_isIosNative()) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    _onTokenRefresh = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) => _persistToken(profileService: profileService, token: token),
    );

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((message) async {
      await _onForegroundMessage(message);
      _deliverToInbox(message);
    });

    await _attachOpenedAppInboxDelivery();

    final token = await _fetchFcmToken();
    if (token != null && token.isNotEmpty) {
      await _persistToken(profileService: profileService, token: token);
    }
  }

  Future<String?> _fetchFcmToken() async {
    try {
      if (kIsWeb) {
        return FirebaseMessaging.instance.getToken(
          vapidKey: AppConfig.firebaseWebVapidKey.trim(),
        );
      }
      return FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('BookingPushNotifications: getToken – $e\n$st');
      }
      return null;
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
    if (_localNotificationsReady || kIsWeb) return;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    await _local.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    if (_isAndroidNative()) {
      const bookingChannel = AndroidNotificationChannel(
        madBeautyBookingAndroidChannelId,
        'MadBeauty – réservations',
        description: 'Demandes et statuts de réservation.',
        importance: Importance.high,
      );
      const messagingChannel = AndroidNotificationChannel(
        madBeautyMessagingAndroidChannelId,
        'MadBeauty – messages',
        description: 'Nouveaux messages et discussions.',
        importance: Importance.high,
      );
      final androidImplementation = _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.createNotificationChannel(bookingChannel);
      await androidImplementation?.createNotificationChannel(messagingChannel);
    }

    _localNotificationsReady = true;
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return;
      final data = Map<String, dynamic>.from(decoded);
      _onPushDataOpened?.call(data);
    } catch (_) {
      /* payload invalide */
    }
  }

  String? _payloadFromData(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    return jsonEncode(data);
  }

  /// Dialogue système uniquement lors du premier flux (persisté localement).
  Future<void> _requestPermissionsFirstLaunch() async {
    final cache = LocalCacheService.instance;

    if (cache.pushPermissionPrompted) return;

    if (_isAndroidNative()) {
      await requestPlatformNotifications();
    } else if (_isIosNative()) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (kIsWeb) {
      await requestPlatformNotifications();
    }

    await cache.setPushPermissionPrompted();
  }

  Future<void> showLocalAlert({
    required String title,
    required String body,
  }) async {
    final trimmedBody = body.trim();
    if (trimmedBody.isEmpty) return;

    if (kIsWeb) {
      await showWebBrowserNotification(title: title, body: trimmedBody);
      return;
    }

    await _initializeLocalNotifications();

    const androidDetails = AndroidNotificationDetails(
      madBeautyBookingAndroidChannelId,
      'MadBeauty – réservations',
      channelDescription: 'Demandes et statuts de réservation.',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _local.show(
      trimmedBody.hashCode,
      title.trim().isEmpty ? 'MadBeauty' : title.trim(),
      trimmedBody,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    final type = data['type']?.toString() ?? '';
    final isMessaging = type == 'message' || type == 'bug_report_message';

    final title = notification?.title ??
        (isMessaging ? 'Nouveau message' : 'MadBeauty');
    final body = notification?.body ??
        (data['body'] as String?) ??
        (isMessaging ? 'Tu as reçu un message.' : '');

    if (body.trim().isEmpty && notification == null) return;

    if (kIsWeb) {
      await showWebBrowserNotification(
        title: title,
        body: body.trim().isEmpty ? 'MadBeauty' : body,
        payload: _payloadFromData(data),
      );
      return;
    }

    final channelId = isMessaging
        ? madBeautyMessagingAndroidChannelId
        : madBeautyBookingAndroidChannelId;
    final channelName = isMessaging
        ? 'MadBeauty – messages'
        : 'MadBeauty – réservations';
    final channelDescription = isMessaging
        ? 'Nouveaux messages et discussions.'
        : 'Demandes et statuts de réservation.';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _local.show(
      Object.hash(type, body).hashCode,
      title,
      body.trim().isEmpty ? 'MadBeauty' : body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: _payloadFromData(data),
    );
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
      final token = await _fetchFcmToken();
      if (token != null && token.isNotEmpty) {
        await profileService?.upsertFcmToken(userId: userId, token: token);
      }
    } catch (_) {}
  }
}
