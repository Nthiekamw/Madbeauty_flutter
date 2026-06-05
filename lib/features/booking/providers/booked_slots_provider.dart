import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/booking/booking_reservation_providers.dart';
import '../models/booked_slots_query.dart';
import '../models/booking_slot.dart';

final bookedSlotsProvider = FutureProvider.autoDispose
    .family<Set<BookingSlot>, BookedSlotsQuery>((ref, _) async {
      final service = ref.watch(bookingReservationServiceProvider);
      if (service == null) return const {};
      // Le verrouillage des créneaux est désormais géré par la capacité
      // dans DisponibiliteService (créneaux complets exclus en amont).
      return const {};
    });

