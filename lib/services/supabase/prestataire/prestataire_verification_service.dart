import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../supabase_service.dart';

class PrestataireVerificationService {
  PrestataireVerificationService(this._client);

  final SupabaseClient _client;

  factory PrestataireVerificationService.fromEnv() =>
      PrestataireVerificationService(SupabaseService.client);

  Future<void> requestVerification() async {
    await SupabaseErrorHandler.run(
      operation: 'prestataireVerification.request',
      action: () async {
        await _client.rpc('request_prestataire_verification');
      },
    );
  }

  Future<DateTime?> fetchRequestedAt() async {
    return SupabaseErrorHandler.run(
      operation: 'prestataireVerification.fetchRequestedAt',
      action: () async {
        final userId = _client.auth.currentUser?.id;
        if (userId == null) return null;
        final row = await _client
            .from('prestataire_profiles')
            .select('verification_requested_at, is_verified')
            .eq('user_id', userId)
            .maybeSingle();
        if (row == null) return null;
        if (row['is_verified'] == true) return null;
        return DateTime.tryParse(
          (row['verification_requested_at'] as String?) ?? '',
        );
      },
    );
  }
}
