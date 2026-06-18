import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_booking_platform_fee_settings.dart';
import '../supabase_service.dart';

class AdminBookingPlatformFeeService {
  AdminBookingPlatformFeeService(this._client);

  final SupabaseClient _client;

  factory AdminBookingPlatformFeeService.fromEnv() =>
      AdminBookingPlatformFeeService(SupabaseService.client);

  Future<AdminBookingPlatformFeeSettings> getSettings() async {
    return SupabaseErrorHandler.run(
      operation: 'adminBookingPlatformFee.getSettings',
      action: () async {
        final result = await _client.rpc('admin_get_booking_platform_fee_settings');
        if (result is Map<String, dynamic>) {
          return AdminBookingPlatformFeeSettings.fromJson(result);
        }
        if (result is Map) {
          return AdminBookingPlatformFeeSettings.fromJson(
            Map<String, dynamic>.from(result),
          );
        }
        return const AdminBookingPlatformFeeSettings(
          feeCents: 0,
          freeBookingCount: 2,
        );
      },
    );
  }

  Future<AdminBookingPlatformFeeSettings> updateSettings({
    required int feeCents,
    required int freeBookingCount,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminBookingPlatformFee.updateSettings',
      action: () async {
        final result = await _client.rpc(
          'admin_update_booking_platform_fee',
          params: {
            'p_fee_cents': feeCents,
            'p_free_booking_count': freeBookingCount,
          },
        );
        if (result is Map<String, dynamic>) {
          return AdminBookingPlatformFeeSettings.fromJson(result);
        }
        if (result is Map) {
          return AdminBookingPlatformFeeSettings.fromJson(
            Map<String, dynamic>.from(result),
          );
        }
        return getSettings();
      },
    );
  }
}
