import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/availability/horaire_plage.dart';
import '../../../core/models/domain/availability/indisponibilite.dart';
import '../../../core/models/domain/availability/time_slot.dart';
import '../../../features/booking/models/booking_availability_rules.dart';
import '../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import 'current_prestataire_provider.dart';

/// Paramètre pour [creneauxDisponiblesProvider].
typedef CreneauxDisponiblesQuery = ({
  String prestataireId,
  DateTime date,
});

/// Horaires hebdomadaires du prestataire connecté.
final prestataireHorairesProvider =
    FutureProvider.autoDispose<List<HorairePlage>>((ref) async {
      final service = ref.watch(disponibiliteServiceProvider);
      final presta = await ref.watch(currentPrestataireProvider.future);
      if (service == null || presta == null) return const [];
      return service.getHoraires(presta.id);
    });

/// Créneaux réservables pour un prestataire à une date donnée.
final creneauxDisponiblesProvider = FutureProvider.autoDispose
    .family<List<TimeSlot>, CreneauxDisponiblesQuery>((ref, query) async {
      final service = ref.watch(disponibiliteServiceProvider);
      if (service == null) return const [];
      return service.getCreneauxDisponibles(
        query.prestataireId,
        query.date,
      );
    });

/// Règles calendrier client dérivées des horaires Supabase.
final bookingAvailabilityForPrestaProvider = FutureProvider.autoDispose
    .family<BookingAvailabilityRules, String>((ref, prestataireId) async {
      final service = ref.watch(disponibiliteServiceProvider);
      if (service == null) {
        return const BookingAvailabilityRules(slotsByWeekday: {});
      }
      final horaires = await service.getHoraires(prestataireId);
      if (horaires.isEmpty) {
        return const BookingAvailabilityRules(slotsByWeekday: {});
      }
      return service.buildAvailabilityRules(horaires);
    });

/// Congés / fermetures à venir du prestataire connecté.
final prestataireIndisponibilitesProvider =
    FutureProvider.autoDispose<List<Indisponibilite>>((ref) async {
      final service = ref.watch(disponibiliteServiceProvider);
      final presta = await ref.watch(currentPrestataireProvider.future);
      if (service == null || presta == null) return const [];
      return service.listIndisponibilites(presta.id);
    });

void invalidateDisponibiliteProviders(WidgetRef ref) {
  ref.invalidate(prestataireHorairesProvider);
  ref.invalidate(prestataireIndisponibilitesProvider);
  ref.invalidate(bookingAvailabilityForPrestaProvider);
  ref.invalidate(creneauxDisponiblesProvider);
}
