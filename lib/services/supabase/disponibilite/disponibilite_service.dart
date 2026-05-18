import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/availability/horaire_plage.dart';
import '../../../core/models/domain/availability/time_slot.dart';
import '../../../features/booking/models/booking_availability_rules.dart';
import '../../../features/booking/models/booking_slot.dart';
import 'disponibilite_dow.dart';

class DisponibiliteService {
  DisponibiliteService(this._client);

  final SupabaseClient _client;

  static const slotStepMinutes = 30;

  static const _activeReservationStatuses = {
    'en_attente',
    'pending',
    'confirmee',
    'confirmée',
    'confirmed',
  };

  Future<List<HorairePlage>> getHoraires(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'disponibilite.getHoraires',
        action: () async {
          final response = await _client
              .from('disponibilites')
              .select('jour_semaine, heure_debut, heure_fin')
              .eq('prestataire_id', prestataireId)
              .order('jour_semaine')
              .order('heure_debut');

          return (response as List<dynamic>).map((raw) {
            final row = Map<String, dynamic>.from(raw as Map);
            return HorairePlage(
              jourSemaine: row['jour_semaine'] as int,
              heureDebut: _parseTime(row['heure_debut']),
              heureFin: _parseTime(row['heure_fin']),
            );
          }).toList();
        },
      );

  Future<void> setHoraires(
    String prestataireId,
    List<HorairePlage> horaires,
  ) =>
      SupabaseErrorHandler.run(
        operation: 'disponibilite.setHoraires',
        action: () async {
          await _client
              .from('disponibilites')
              .delete()
              .eq('prestataire_id', prestataireId);

          if (horaires.isEmpty) return;

          final payload = horaires
              .map(
                (h) => {
                  'prestataire_id': prestataireId,
                  'jour_semaine': h.jourSemaine,
                  'heure_debut': _formatTime(h.heureDebut),
                  'heure_fin': _formatTime(h.heureFin),
                },
              )
              .toList();

          await _client.from('disponibilites').insert(payload);
        },
      );

  Future<void> addIndisponibilite(
    String prestataireId,
    DateTime dateDebut,
    DateTime dateFin,
  ) =>
      SupabaseErrorHandler.run(
        operation: 'disponibilite.addIndisponibilite',
        action: () async {
          await _client.from('indisponibilites').insert({
            'prestataire_id': prestataireId,
            'date_debut': dateDebut.toUtc().toIso8601String(),
            'date_fin': dateFin.toUtc().toIso8601String(),
          });
        },
      );

  Future<List<TimeSlot>> getCreneauxDisponibles(
    String prestataireId,
    DateTime date,
  ) =>
      SupabaseErrorHandler.run(
        operation: 'disponibilite.getCreneauxDisponibles',
        action: () async {
          final day = DateTime(date.year, date.month, date.day);
          final pgDow = DisponibiliteDow.fromDartWeekday(day.weekday);

          if (await _isDayFullyBlocked(prestataireId, day)) {
            return const [];
          }

          final plages = await getHoraires(prestataireId);
          final dayPlages =
              plages.where((p) => p.jourSemaine == pgDow).toList();
          if (dayPlages.isEmpty) return const [];

          final reserved = await _reservedSlots(prestataireId, day);
          final indispos = await _indisponibilitesForDay(prestataireId, day);

          final slots = <TimeSlot>[];
          for (final plage in dayPlages) {
            for (final slot in _generateSlots(plage)) {
              final at = slot.onDay(day);
              if (_isBlocked(at, indispos, reserved)) continue;
              slots.add(slot);
            }
          }

          slots.sort((a, b) {
            final cmp = a.hour.compareTo(b.hour);
            return cmp != 0 ? cmp : a.minute.compareTo(b.minute);
          });
          return slots;
        },
      );

  BookingAvailabilityRules buildAvailabilityRules(List<HorairePlage> horaires) {
    final map = <int, List<BookingSlot>>{
      for (final d in [
        DateTime.monday,
        DateTime.tuesday,
        DateTime.wednesday,
        DateTime.thursday,
        DateTime.friday,
        DateTime.saturday,
        DateTime.sunday,
      ])
        d: const [],
    };

    for (final plage in horaires) {
      final dartDay = DisponibiliteDow.toDartWeekday(plage.jourSemaine);
      final slots = _generateSlots(plage)
          .map((s) => BookingSlot(hour: s.hour, minute: s.minute))
          .toList();
      map[dartDay] = [...map[dartDay] ?? const [], ...slots];
    }

    return BookingAvailabilityRules(slotsByWeekday: map);
  }

  Future<bool> _isDayFullyBlocked(String prestataireId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final response = await _client
        .from('indisponibilites')
        .select('date_debut, date_fin')
        .eq('prestataire_id', prestataireId)
        .lt('date_debut', end.toUtc().toIso8601String())
        .gt('date_fin', start.toUtc().toIso8601String());

    for (final raw in response as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final deb = DateTime.parse(row['date_debut'] as String).toLocal();
      final fin = DateTime.parse(row['date_fin'] as String).toLocal();
      if (!deb.isAfter(start) && !fin.isBefore(end)) return true;
    }
    return false;
  }

  Future<List<DateTimeRange>> _indisponibilitesForDay(
    String prestataireId,
    DateTime day,
  ) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final response = await _client
        .from('indisponibilites')
        .select('date_debut, date_fin')
        .eq('prestataire_id', prestataireId)
        .lt('date_debut', end.toUtc().toIso8601String())
        .gt('date_fin', start.toUtc().toIso8601String());

    return (response as List<dynamic>).map((raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      return DateTimeRange(
        start: DateTime.parse(row['date_debut'] as String).toLocal(),
        end: DateTime.parse(row['date_fin'] as String).toLocal(),
      );
    }).toList();
  }

  Future<Set<TimeSlot>> _reservedSlots(String prestataireId, DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final response = await _client
        .from('reservations')
        .select('date_heure, statut')
        .eq('prestataire_id', prestataireId)
        .gte('date_heure', start.toUtc().toIso8601String())
        .lt('date_heure', end.toUtc().toIso8601String());

    final out = <TimeSlot>{};
    for (final raw in response as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final statut = (row['statut'] as String?)?.trim().toLowerCase() ?? '';
      final normalized = statut.replaceAll('é', 'e');
      if (!_activeReservationStatuses.contains(normalized)) continue;
      final dt = DateTime.tryParse(row['date_heure'] as String)?.toLocal();
      if (dt != null) out.add(TimeSlot.fromDateTime(dt));
    }
    return out;
  }

  List<TimeSlot> _generateSlots(HorairePlage plage) {
    final slots = <TimeSlot>[];
    var cursor = plage.heureDebut.hour * 60 + plage.heureDebut.minute;
    final endMin = plage.heureFin.hour * 60 + plage.heureFin.minute;
    while (cursor + slotStepMinutes <= endMin) {
      slots.add(TimeSlot(hour: cursor ~/ 60, minute: cursor % 60));
      cursor += slotStepMinutes;
    }
    return slots;
  }

  bool _isBlocked(
    DateTime at,
    List<DateTimeRange> indispos,
    Set<TimeSlot> reserved,
  ) {
    final slot = TimeSlot.fromDateTime(at);
    if (reserved.contains(slot)) return true;
    for (final range in indispos) {
      if (!at.isBefore(range.start) && at.isBefore(range.end)) return true;
    }
    return false;
  }

  TimeOfDay _parseTime(Object? value) {
    final text = value?.toString() ?? '09:00';
    final parts = text.split(':');
    final h = int.tryParse(parts.first) ?? 9;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: h, minute: m);
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}
