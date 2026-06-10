import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_reservation_filters.dart';
import '../../../core/models/domain/admin/admin_reservation_summary.dart';
import '../supabase_service.dart';

class AdminReservationsService {
  AdminReservationsService(this._client);

  final SupabaseClient _client;

  factory AdminReservationsService.fromEnv() =>
      AdminReservationsService(SupabaseService.client);

  Future<List<AdminReservationSummary>> listReservations({
    AdminReservationFilters filters = const AdminReservationFilters(),
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminReservations.listReservations',
      action: () async {
        final rows = await _client.rpc(
          'admin_list_reservations',
          params: {
            'p_limit': filters.limit,
            'p_statut': _emptyToNull(filters.statut),
            'p_payment_status': _emptyToNull(filters.paymentStatus),
            'p_from_date': filters.fromDate?.toUtc().toIso8601String(),
            'p_to_date': filters.toDate?.toUtc().toIso8601String(),
          },
        );
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(_mapRow).toList();
      },
    );
  }

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  AdminReservationSummary _mapRow(Map<String, dynamic> row) {
    return AdminReservationSummary(
      id: row['id'] as String? ?? '',
      dateHeure: DateTime.tryParse((row['date_heure'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      statut: row['statut'] as String? ?? '',
      paymentStatus: row['payment_status'] as String?,
      paymentMode: row['payment_mode'] as String?,
      amountCents: (row['amount_cents'] as num?)?.toInt(),
      currency: row['currency'] as String?,
      clientName: row['client_name'] as String?,
      prestataireSalon: row['prestataire_salon'] as String?,
      serviceName: row['service_name'] as String?,
      stripePaymentIntentId: row['stripe_payment_intent_id'] as String?,
      paidAt: DateTime.tryParse((row['paid_at'] as String?) ?? ''),
    );
  }
}
