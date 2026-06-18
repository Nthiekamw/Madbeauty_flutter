import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/booking/booking_platform_fee_settings.dart';
import '../../../services/supabase/booking/booking_platform_fee_service.dart';

final bookingPlatformFeeServiceProvider =
    Provider<BookingPlatformFeeService?>((ref) {
  return BookingPlatformFeeService.fromEnv();
});

final bookingPlatformFeeSettingsProvider =
    FutureProvider.autoDispose<BookingPlatformFeeSettings>((ref) async {
  final service = ref.watch(bookingPlatformFeeServiceProvider);
  if (service == null) return BookingPlatformFeeSettings.defaults;
  return service.getSettings();
});
