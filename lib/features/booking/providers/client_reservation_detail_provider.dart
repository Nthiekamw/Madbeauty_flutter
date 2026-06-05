import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/booking/booking_service_providers.dart';
import '../models/client_reservation_summary.dart';

final clientReservationDetailProvider = FutureProvider.autoDispose
    .family<ClientReservationSummary?, String>((ref, reservationId) async {
  final service = ref.watch(bookingServiceProvider);
  if (service == null) return null;
  return service.getClientReservationDetail(reservationId);
});
