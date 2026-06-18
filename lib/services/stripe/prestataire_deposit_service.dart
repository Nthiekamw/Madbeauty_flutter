import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/supabase_error_handler.dart';
import '../supabase/supabase_service.dart';

class PrestataireDepositService {
  PrestataireDepositService(this._client);

  final SupabaseClient _client;

  factory PrestataireDepositService.fromEnv() =>
      PrestataireDepositService(SupabaseService.client);

  Future<bool> setDepositOptionEnabled(bool enabled) async {
    return SupabaseErrorHandler.run(
      operation: 'prestataireDeposit.setOption',
      action: () async {
        final result = await _client.rpc(
          'prestataire_set_deposit_option',
          params: {'p_enabled': enabled},
        );
        if (result is bool) return result;
        return enabled;
      },
    );
  }
}
