import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'booking_reservation_service.dart';

final bookingReservationServiceProvider = Provider<BookingReservationService?>((
  ref,
) {
  if (!AppConfig.hasSupabase) return null;
  return BookingReservationService(SupabaseService.client);
});
