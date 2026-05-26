import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../booking/models/booking_availability_rules.dart';
import '../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import 'disponibilite_provider.dart';

/// `true` si le prestataire a au moins un créneau réservable dans les 14 prochains jours.
final prestataireHasOpenSlotsProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, prestataireId) async {
      final service = ref.watch(disponibiliteServiceProvider);
      if (service == null) return false;

      final now = DateTime.now();
      final today = bookingDateOnly(now);
      final rules = await ref.watch(
        bookingAvailabilityForPrestaProvider(prestataireId).future,
      );

      if (rules.slotsByWeekday.values.every((slots) => slots.isEmpty)) {
        return false;
      }

      final horizon = today.add(const Duration(days: 14));
      final last = rules.lastDay(now);
      final end = horizon.isBefore(last) ? horizon : last;

      for (var i = 0; i <= 14; i++) {
        final day = today.add(Duration(days: i));
        if (day.isAfter(end)) break;
        if (!rules.isAvailableDay(day, now: now)) continue;

        final slots = await service.getCreneauxDisponibles(prestataireId, day);
        if (slots.isNotEmpty) return true;
      }

      return false;
    });
