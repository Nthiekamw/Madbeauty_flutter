import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Rappels locaux J-1 et H-2 pour réservations confirmées (côté client).
class BookingLocalReminders {
  BookingLocalReminders._();

  static final BookingLocalReminders instance = BookingLocalReminders._();
  static var _tzReady = false;
  static var _pluginReady = false;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'madbeauty_reminders';
  static const _dayBeforeIdBase = 40000;
  static const _twoHoursIdBase = 50000;

  Future<void> initialize() async {
    if (_pluginReady) return;
    await _ensureTz();

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    await _plugin.initialize(const InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    ));

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        'Rappels de rendez-vous',
        description: 'Rappels avant tes réservations.',
        importance: Importance.defaultImportance,
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(channel);
    }

    _pluginReady = true;
  }

  Future<void> _ensureTz() async {
    if (_tzReady) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Paris'));
    _tzReady = true;
  }

  Future<void> syncForReservations(
    List<({String id, DateTime dateHeure, String title, String statut})> items,
  ) async {
    await initialize();
    final now = DateTime.now();

    for (final item in items) {
      final s = item.statut.trim().toLowerCase().replaceAll('é', 'e');
      if (!const {'confirmee', 'confirmed', 'validee', 'valide'}.contains(s)) {
        await _cancel(item.id);
        continue;
      }
      if (item.dateHeure.isBefore(now)) {
        await _cancel(item.id);
        continue;
      }
      await _schedule(
        reservationId: item.id,
        when: item.dateHeure,
        title: item.title,
      );
    }
  }

  Future<void> _schedule({
    required String reservationId,
    required DateTime when,
    required String title,
  }) async {
    final dayBefore = when.subtract(const Duration(hours: 24));
    final twoHours = when.subtract(const Duration(hours: 2));
    final hash = reservationId.hashCode.abs() % 10000;

    await _cancel(reservationId);

    if (dayBefore.isAfter(DateTime.now())) {
      await _zoned(
        id: _dayBeforeIdBase + hash,
        scheduled: dayBefore,
        notifTitle: 'Rappel – demain',
        body: '$title demain à ${_formatTime(when)}',
      );
    }
    if (twoHours.isAfter(DateTime.now())) {
      await _zoned(
        id: _twoHoursIdBase + hash,
        scheduled: twoHours,
        notifTitle: 'Rappel – dans 2 h',
        body: '$title à ${_formatTime(when)}',
      );
    }
  }

  Future<void> _zoned({
    required int id,
    required DateTime scheduled,
    required String notifTitle,
    required String body,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        notifTitle,
        body,
        tz.TZDateTime.from(scheduled, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Rappels de rendez-vous',
            channelDescription: 'Rappels avant tes réservations.',
            importance: Importance.defaultImportance,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('BookingLocalReminders: $e');
    }
  }

  Future<void> _cancel(String reservationId) async {
    final hash = reservationId.hashCode.abs() % 10000;
    await _plugin.cancel(_dayBeforeIdBase + hash);
    await _plugin.cancel(_twoHoursIdBase + hash);
  }

  static String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

