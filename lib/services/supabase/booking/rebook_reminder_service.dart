import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

/// Rappels « réserver à nouveau » (4 / 6 semaines).
class RebookReminderService {
  RebookReminderService(this._client);

  final SupabaseClient _client;

  Future<void> schedule({
    required String reservationId,
    required int intervalWeeks,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'rebookReminder.schedule',
      action: () async {
        if (intervalWeeks != 4 && intervalWeeks != 6) {
          throw ArgumentError('intervalWeeks must be 4 or 6');
        }
        await _client.rpc(
          'schedule_rebook_reminder',
          params: {
            'p_reservation_id': reservationId,
            'p_interval_weeks': intervalWeeks,
          },
        );
      },
    );
  }
}
