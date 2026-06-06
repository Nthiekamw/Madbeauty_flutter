import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/admin/admin_reservations_service.dart';
import '../models/admin_reservation_filters.dart';
import '../models/admin_reservation_summary.dart';

final adminReservationsServiceProvider = Provider<AdminReservationsService?>((ref) {
  return AdminReservationsService.fromEnv();
});

final adminReservationsProvider = FutureProvider.autoDispose
    .family<List<AdminReservationSummary>, AdminReservationFilters>((
  ref,
  filters,
) async {
  final service = ref.watch(adminReservationsServiceProvider);
  if (service == null) return const [];
  return service.listReservations(filters: filters);
});
