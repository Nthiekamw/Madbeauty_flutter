import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

class BookingReservationService {
  BookingReservationService(this._client);

  final SupabaseClient _client;

  Future<List<DateTime>> getBookedSlots({
    required String prestataireId,
    required String serviceId,
    required DateTime day,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'bookingReservation.getBookedSlots',
      action: () async {
        final response = await _client.rpc(
          'get_booked_booking_slots',
          params: {
            'p_prestataire_id': prestataireId,
            'p_service_id': serviceId,
            'p_day': _formatDateParam(day),
          },
        );

        return (response as List<dynamic>)
            .map((row) {
              final value = (row as Map<String, dynamic>)['date_heure'];
              if (value is! String) return null;
              return DateTime.tryParse(value)?.toLocal();
            })
            .whereType<DateTime>()
            .toList();
      },
    );
  }

  String _formatDateParam(DateTime day) {
    final year = day.year.toString().padLeft(4, '0');
    final month = day.month.toString().padLeft(2, '0');
    final date = day.day.toString().padLeft(2, '0');
    return '$year-$month-$date';
  }
}
