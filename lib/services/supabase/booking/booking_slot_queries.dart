import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_mappers.dart';

/// Capacité créneau et comptage réservations actives.
class BookingSlotQueries {
  BookingSlotQueries(this._client);

  final SupabaseClient _client;

  Future<int> slotCapacityFor(String prestataireId, DateTime at) async {
    final local = at.toLocal();
    final pgDow = local.weekday % 7;
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final timeText = '$hh:$mm:00';

    final override = await _client
        .from('disponibilite_capacity_overrides')
        .select('capacite_simultanee')
        .eq('prestataire_id', prestataireId)
        .eq('jour_semaine', pgDow)
        .lte('heure_debut', timeText)
        .gt('heure_fin', timeText)
        .limit(1)
        .maybeSingle();
    final overrideCapacity = (override?['capacite_simultanee'] as num?)
        ?.toInt();
    if (overrideCapacity != null && overrideCapacity > 0) {
      return overrideCapacity;
    }

    final response = await _client
        .from('disponibilites')
        .select('capacite_simultanee')
        .eq('prestataire_id', prestataireId)
        .eq('jour_semaine', pgDow)
        .lte('heure_debut', timeText)
        .gt('heure_fin', timeText)
        .limit(1)
        .maybeSingle();

    return (response?['capacite_simultanee'] as num?)?.toInt() ?? 1;
  }

  Future<int> activeReservationsCountAtSlot({
    required String prestataireId,
    required DateTime at,
  }) async {
    final start = BookingMappers.startOfMinuteLocal(at);
    final end = start.add(const Duration(minutes: 1));
    final response = await _client
        .from('reservations')
        .select('id, statut')
        .eq('prestataire_id', prestataireId)
        .gte('date_heure', start.toUtc().toIso8601String())
        .lt('date_heure', end.toUtc().toIso8601String());

    var count = 0;
    for (final raw in response as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final normalized = BookingMappers.normalizeStatut(row['statut']);
      if (const {'en_attente', 'pending', 'confirmee', 'confirmed'}
          .contains(normalized)) {
        count += 1;
      }
    }
    return count;
  }
}
