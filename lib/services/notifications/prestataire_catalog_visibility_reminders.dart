import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'booking_local_reminders.dart';

/// Rappels locaux : profil prêt mais pas visible catalogue (abonnement manquant).
class PrestataireCatalogVisibilityReminders {
  PrestataireCatalogVisibilityReminders._();

  static final PrestataireCatalogVisibilityReminders instance =
      PrestataireCatalogVisibilityReminders._();

  static const _channelId = 'madbeauty_presta_visibility';
  static const _id24h = 61001;
  static const _id72h = 61002;
  static const _id7d = 61003;

  Future<void> initialize() async {
    await BookingLocalReminders.instance.initialize();
    if (!Platform.isAndroid) return;

    const channel = AndroidNotificationChannel(
      _channelId,
      'Visibilité catalogue pro',
      description:
          'Rappels pour compléter ton profil et apparaître dans le catalogue.',
      importance: Importance.defaultImportance,
    );
    final android = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
  }

  Future<void> scheduleNudges({
    required String title,
    required String body,
  }) async {
    await initialize();
    await cancelAll();

    final now = DateTime.now();
    await _schedule(
      id: _id24h,
      at: now.add(const Duration(hours: 24)),
      title: title,
      body: body,
    );
    await _schedule(
      id: _id72h,
      at: now.add(const Duration(hours: 72)),
      title: title,
      body: body,
    );
    await _schedule(
      id: _id7d,
      at: now.add(const Duration(days: 7)),
      title: title,
      body: body,
    );
  }

  Future<void> cancelAll() async {
    final plugin = FlutterLocalNotificationsPlugin();
    for (final id in [_id24h, _id72h, _id7d]) {
      await plugin.cancel(id);
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    if (!at.isAfter(DateTime.now())) return;
    final plugin = FlutterLocalNotificationsPlugin();
    try {
      await plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(at, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Visibilité catalogue pro',
            channelDescription:
                'Rappels pour retrouver ta visibilité sur le catalogue.',
            importance: Importance.defaultImportance,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('PrestaCatalogVisibilityReminders: $e');
    }
  }
}
