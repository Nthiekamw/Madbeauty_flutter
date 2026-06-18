import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/booking/booking_reservation_providers.dart';
import '../models/booked_slots_query.dart';
import '../models/booking_slot.dart';

final bookedSlotsProvider = FutureProvider.autoDispose
    .family<Set<BookingSlot>, BookedSlotsQuery>((ref, query) async {
      final service = ref.watch(bookingReservationServiceProvider);
      if (service == null) return const {};
      final booked = await service.getBookedSlots(
        prestataireId: query.prestataireId,
        serviceId: query.serviceId,
        day: query.normalizedDay,
      );
      return booked.map(BookingSlot.fromDateTime).toSet();
    });

