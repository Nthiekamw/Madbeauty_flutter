import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/booking/booking_platform_fee_settings.dart';
import '../supabase_service.dart';

class BookingPlatformFeeService {
  BookingPlatformFeeService(this._client);

  final SupabaseClient _client;

  factory BookingPlatformFeeService.fromEnv() =>
      BookingPlatformFeeService(SupabaseService.client);

  Future<BookingPlatformFeeSettings> getSettings() async {
    return SupabaseErrorHandler.run(
      operation: 'bookingPlatformFee.getSettings',
      action: () async {
        final result = await _client.rpc('get_booking_platform_fee_settings');
        if (result is Map<String, dynamic>) {
          return BookingPlatformFeeSettings.fromJson(result);
        }
        if (result is Map) {
          return BookingPlatformFeeSettings.fromJson(
            Map<String, dynamic>.from(result),
          );
        }
        return BookingPlatformFeeSettings.defaults;
      },
    );
  }
}
