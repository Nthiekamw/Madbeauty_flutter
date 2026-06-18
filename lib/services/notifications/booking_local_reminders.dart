import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_strings.dart';
import 'booking_reminder_schedule.dart';

/// Rappels locaux avant RDV confirmés (client et prestataire).
class BookingLocalReminders {
  BookingLocalReminders._();

  static final BookingLocalReminders instance = BookingLocalReminders._();
  static var _tzReady = false;
  static var _pluginReady = false;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'madbeauty_reminders';

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
    List<({String id, DateTime dateHeure, String title, String statut})> items, {
    BookingReminderAudience audience = BookingReminderAudience.client,
  }) async {
    await initialize();
    final now = DateTime.now();

    for (final item in items) {
      if (!bookingReminderStatusEligible(item.statut)) {
        await _cancel(item.id, audience: audience);
        continue;
      }
      if (!item.dateHeure.isAfter(now)) {
        await _cancel(item.id, audience: audience);
        continue;
      }
      await _schedule(
        reservationId: item.id,
        when: item.dateHeure,
        title: item.title,
        audience: audience,
      );
    }
  }

  Future<void> _schedule({
    required String reservationId,
    required DateTime when,
    required String title,
    required BookingReminderAudience audience,
  }) async {
    final now = DateTime.now();
    final slots = upcomingBookingReminderSlots(
      appointmentAt: when,
      now: now,
    );

    await _cancel(reservationId, audience: audience);

    for (final slot in slots) {
      final copy = _notificationCopy(
        audience: audience,
        kind: slot.kind,
        title: title,
        appointmentAt: when,
      );
      await _zoned(
        id: bookingReminderNotificationId(
          reservationId: reservationId,
          kind: slot.kind,
          audience: audience,
        ),
        scheduled: slot.at,
        notifTitle: copy.title,
        body: copy.body,
      );
    }
  }

  ({String title, String body}) _notificationCopy({
    required BookingReminderAudience audience,
    required BookingReminderKind kind,
    required String title,
    required DateTime appointmentAt,
  }) {
    final time = _formatTime(appointmentAt);
    if (audience == BookingReminderAudience.prestataire) {
      return switch (kind) {
        BookingReminderKind.dayBefore => (
            title: DiscPrestaAgenda.reminderDayBeforeTitle,
            body: DiscPrestaAgenda.reminderDayBeforeBody(title, time),
          ),
        BookingReminderKind.twoHours => (
            title: DiscPrestaAgenda.reminderTwoHoursTitle,
            body: DiscPrestaAgenda.reminderSoonBody(title, time),
          ),
        BookingReminderKind.thirtyMinutes => (
            title: DiscPrestaAgenda.reminderThirtyMinTitle,
            body: DiscPrestaAgenda.reminderSoonBody(title, time),
          ),
        BookingReminderKind.fifteenMinutes => (
            title: DiscPrestaAgenda.reminderFifteenMinTitle,
            body: DiscPrestaAgenda.reminderSoonBody(title, time),
          ),
      };
    }

    return switch (kind) {
      BookingReminderKind.dayBefore => (
          title: DiscBk.reminderDayBeforeTitle,
          body: DiscBk.reminderDayBeforeBody(title, time),
        ),
      BookingReminderKind.twoHours => (
          title: DiscBk.reminderTwoHoursTitle,
          body: DiscBk.reminderSoonBody(title, time),
        ),
      BookingReminderKind.thirtyMinutes => (
          title: DiscBk.reminderThirtyMinTitle,
          body: DiscBk.reminderSoonBody(title, time),
        ),
      BookingReminderKind.fifteenMinutes => (
          title: DiscBk.reminderFifteenMinTitle,
          body: DiscBk.reminderSoonBody(title, time),
        ),
    };
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

  Future<void> _cancel(
    String reservationId, {
    required BookingReminderAudience audience,
  }) async {
    for (final kind in BookingReminderKind.values) {
      await _plugin.cancel(
        bookingReminderNotificationId(
          reservationId: reservationId,
          kind: kind,
          audience: audience,
        ),
      );
    }
  }

  static String _formatTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
