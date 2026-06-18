import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/services/notifications/booking_reminder_schedule.dart';

void main() {
  group('upcomingBookingReminderSlots', () {
    test('inclut 30 min et 15 min si H-2 est passé', () {
      final appointment = DateTime(2026, 6, 17, 15, 30);
      final now = DateTime(2026, 6, 17, 14, 0);

      final slots = upcomingBookingReminderSlots(
        appointmentAt: appointment,
        now: now,
      );

      expect(
        slots.map((s) => s.kind).toList(),
        [
          BookingReminderKind.thirtyMinutes,
          BookingReminderKind.fifteenMinutes,
        ],
      );
      expect(slots.first.at, DateTime(2026, 6, 17, 15, 0));
      expect(slots.last.at, DateTime(2026, 6, 17, 15, 15));
    });

    test('ne garde que 15 min si 30 min est déjà passé', () {
      final appointment = DateTime(2026, 6, 17, 15, 30);
      final now = DateTime(2026, 6, 17, 15, 12);

      final slots = upcomingBookingReminderSlots(
        appointmentAt: appointment,
        now: now,
      );

      expect(slots.map((s) => s.kind).toList(), [
        BookingReminderKind.fifteenMinutes,
      ]);
      expect(slots.single.at, DateTime(2026, 6, 17, 15, 15));
    });

    test('inclut tous les créneaux futurs avant le RDV', () {
      final appointment = DateTime(2026, 6, 20, 15, 30);
      final now = DateTime(2026, 6, 18, 10, 0);

      final slots = upcomingBookingReminderSlots(
        appointmentAt: appointment,
        now: now,
      );

      expect(slots.map((s) => s.kind).toList(), [
        BookingReminderKind.dayBefore,
        BookingReminderKind.twoHours,
        BookingReminderKind.thirtyMinutes,
        BookingReminderKind.fifteenMinutes,
      ]);
    });

    test('retourne vide si le RDV est passé', () {
      final appointment = DateTime(2026, 6, 17, 14, 0);
      final now = DateTime(2026, 6, 17, 15, 0);

      final slots = upcomingBookingReminderSlots(
        appointmentAt: appointment,
        now: now,
      );

      expect(slots, isEmpty);
    });
  });

  group('bookingReminderNotificationId', () {
    test('sépare client et prestataire', () {
      const id = 'res-abc';
      final client = bookingReminderNotificationId(
        reservationId: id,
        kind: BookingReminderKind.thirtyMinutes,
        audience: BookingReminderAudience.client,
      );
      final presta = bookingReminderNotificationId(
        reservationId: id,
        kind: BookingReminderKind.thirtyMinutes,
        audience: BookingReminderAudience.prestataire,
      );

      expect(client, isNot(presta));
      expect(presta - client, 100000);
    });
  });
}
