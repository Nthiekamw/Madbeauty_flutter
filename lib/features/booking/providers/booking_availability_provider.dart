import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking_availability_rules.dart';
import '../models/booking_slot.dart';

final bookingAvailabilityRulesProvider = Provider<BookingAvailabilityRules>((
  ref,
) {
  // MVP availability policy. Replace this provider with a Supabase-backed
  // planning service when prestataire availability tables are introduced.
  return const BookingAvailabilityRules(
    slotsByWeekday: {
      DateTime.monday: [
        BookingSlot(hour: 9, minute: 0),
        BookingSlot(hour: 10, minute: 30),
        BookingSlot(hour: 14, minute: 0),
        BookingSlot(hour: 15, minute: 30),
      ],
      DateTime.tuesday: [],
      DateTime.wednesday: [
        BookingSlot(hour: 10, minute: 0),
        BookingSlot(hour: 11, minute: 30),
        BookingSlot(hour: 15, minute: 0),
        BookingSlot(hour: 17, minute: 0),
      ],
      DateTime.thursday: [
        BookingSlot(hour: 9, minute: 30),
        BookingSlot(hour: 12, minute: 0),
        BookingSlot(hour: 16, minute: 30),
      ],
      DateTime.friday: [
        BookingSlot(hour: 9, minute: 0),
        BookingSlot(hour: 10, minute: 30),
        BookingSlot(hour: 14, minute: 0),
        BookingSlot(hour: 15, minute: 30),
        BookingSlot(hour: 17, minute: 0),
      ],
      DateTime.saturday: [
        BookingSlot(hour: 10, minute: 0),
        BookingSlot(hour: 11, minute: 30),
        BookingSlot(hour: 13, minute: 30),
      ],
      DateTime.sunday: [],
    },
  );
});

