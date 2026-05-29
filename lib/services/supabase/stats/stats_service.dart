import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/stats/stats_prestataire.dart';
import '../../../features/prestataire/models/prestataire_analytics_period.dart';

class StatsService {
  StatsService(this._client);

  final SupabaseClient _client;

  /// Stats pour une période glissante (`get_prestataire_stats`).
  Future<StatsPrestataire> getStats({
    required String prestataireId,
    required PrestataireAnalyticsPeriod period,
  }) =>
      getStatsForDays(
        prestataireId: prestataireId,
        periodDays: period.days,
      );

  Future<StatsPrestataire> getStatsForDays({
    required String prestataireId,
    required int periodDays,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'stats.getStats',
      action: () async {
        final raw = await _client.rpc(
          'get_prestataire_stats',
          params: {
            'p_prestataire_id': prestataireId,
            'p_period_days': periodDays,
          },
        );

        if (raw is! Map) {
          throw const FormatException(
            'Réponse get_prestataire_stats invalide.',
          );
        }

        return StatsPrestataire.fromJson(Map<String, dynamic>.from(raw));
      },
    );
  }

  /// Agrégats mois calendaire (`stats_prestataire`).
  Future<StatsPrestataire?> getCalendarMonthStats(String prestataireId) {
    return SupabaseErrorHandler.run(
      operation: 'stats.getCalendarMonthStats',
      action: () async {
        final row = await _client
            .from('stats_prestataire')
            .select()
            .eq('prestataire_id', prestataireId)
            .maybeSingle();

        if (row == null) return null;

        final map = Map<String, dynamic>.from(row);
        return StatsPrestataire(
          prestataireId: prestataireId,
          periodDays: 30,
          caPeriodCents: (map['ca_current_month_cents'] as num?)?.toInt() ?? 0,
          caPreviousPeriodCents:
              (map['ca_previous_month_cents'] as num?)?.toInt() ?? 0,
          bookingsPending: (map['bookings_pending'] as num?)?.toInt() ?? 0,
          bookingsConfirmed: (map['bookings_confirmed'] as num?)?.toInt() ?? 0,
          bookingsDone: (map['bookings_done'] as num?)?.toInt() ?? 0,
          bookingsCancelled: (map['bookings_cancelled'] as num?)?.toInt() ?? 0,
          bookingsTotal: (map['bookings_total'] as num?)?.toInt() ?? 0,
          occupancyPercent: 0,
          capacitySlots: 0,
          bookedSlots: 0,
          weekdayHeatmap: const [0, 0, 0, 0, 0, 0, 0],
        );
      },
    );
  }
}
