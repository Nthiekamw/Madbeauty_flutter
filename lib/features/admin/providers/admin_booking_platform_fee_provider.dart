import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/admin/admin_booking_platform_fee_settings.dart';
import '../../../services/supabase/admin/admin_booking_platform_fee_service.dart';

final adminBookingPlatformFeeServiceProvider =
    Provider<AdminBookingPlatformFeeService?>((ref) {
  return AdminBookingPlatformFeeService.fromEnv();
});

final adminBookingPlatformFeeSettingsProvider =
    FutureProvider.autoDispose<AdminBookingPlatformFeeSettings>((ref) async {
  final service = ref.watch(adminBookingPlatformFeeServiceProvider);
  if (service == null) {
    return const AdminBookingPlatformFeeSettings(
      feeCents: 0,
      freeBookingCount: 2,
    );
  }
  return service.getSettings();
});
