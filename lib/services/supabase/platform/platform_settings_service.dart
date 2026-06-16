import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../supabase_service.dart';

class PlatformSettingsService {
  PlatformSettingsService(this._client);

  final SupabaseClient _client;

  factory PlatformSettingsService.fromEnv() =>
      PlatformSettingsService(SupabaseService.client);

  Future<int> getCatalogTrialDays() async {
    return SupabaseErrorHandler.run(
      operation: 'platformSettings.getCatalogTrialDays',
      action: () async {
        final result = await _client.rpc('get_catalog_trial_days');
        if (result is num) return result.toInt();
        return int.tryParse('$result') ?? 90;
      },
    );
  }
}
