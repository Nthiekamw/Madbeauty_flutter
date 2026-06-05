import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

class SlotWaitlistService {
  SlotWaitlistService(this._client);

  final SupabaseClient _client;

  Future<bool> isOnWaitlist({
    required String clientId,
    required String prestataireId,
    required String serviceId,
    required DateTime day,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'slotWaitlist.isOnWaitlist',
        action: () async {
          final date = _dateOnly(day);
          final row = await _client
              .from('slot_waitlist')
              .select('id')
              .eq('client_id', clientId)
              .eq('prestataire_id', prestataireId)
              .eq('service_id', serviceId)
              .eq('date_jour', date)
              .maybeSingle();
          return row != null;
        },
      );

  Future<void> join({
    required String clientId,
    required String prestataireId,
    required String serviceId,
    required DateTime day,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'slotWaitlist.join',
        action: () async {
          await _client.from('slot_waitlist').upsert({
            'client_id': clientId,
            'prestataire_id': prestataireId,
            'service_id': serviceId,
            'date_jour': _dateOnly(day),
          });
        },
      );

  Future<void> leave({
    required String clientId,
    required String prestataireId,
    required String serviceId,
    required DateTime day,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'slotWaitlist.leave',
        action: () async {
          await _client
              .from('slot_waitlist')
              .delete()
              .eq('client_id', clientId)
              .eq('prestataire_id', prestataireId)
              .eq('service_id', serviceId)
              .eq('date_jour', _dateOnly(day));
        },
      );

  static String _dateOnly(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

