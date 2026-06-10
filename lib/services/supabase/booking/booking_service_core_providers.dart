import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../profile/profile_providers.dart';
import '../supabase_service.dart';
import 'booking_service.dart';

final bookingServiceProvider = Provider<BookingService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return BookingService(
    SupabaseService.client,
    ref.watch(profileServiceProvider),
  );
});

/// Détail réservation accessible au client ou prestataire participant ([RLS]).
final bookingDetailProvider = FutureProvider.autoDispose.family<
  Booking?,
  String
>((ref, id) async {
  final svc = ref.watch(bookingServiceProvider);
  if (svc == null) return null;
  return svc.getById(id);
});
