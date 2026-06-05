import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../features/admin/models/admin_verification_request.dart';
import '../supabase_service.dart';

class AdminVerificationService {
  AdminVerificationService(this._client);

  final SupabaseClient _client;

  factory AdminVerificationService.fromEnv() =>
      AdminVerificationService(SupabaseService.client);

  Future<List<AdminVerificationRequest>> listRequests({
    bool onlyPending = false,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminVerification.listRequests',
      action: () async {
        final rows = await _client.rpc(
          'admin_list_prestataire_verification_requests',
          params: {'p_only_pending': onlyPending},
        );
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        if (list.isEmpty) return const [];

        return list.map((row) {
          final userId = row['user_id'] as String? ?? '';
          return AdminVerificationRequest(
            prestataireId: row['id'] as String? ?? '',
            userId: userId,
            displayName: row['display_name'] as String? ?? 'Prestataire',
            nomSalon: row['nom_salon'] as String?,
            ville: row['ville'] as String?,
            isVerified: row['is_verified'] as bool? ?? false,
            verifiedAt: DateTime.tryParse((row['verified_at'] as String?) ?? ''),
          );
        }).toList();
      },
    );
  }

  Future<void> approve({
    required String prestataireId,
    String? note,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'adminVerification.approve',
      action: () async {
        await _client.rpc(
          'approve_prestataire_verification',
          params: {
            'p_prestataire_id': prestataireId,
            'p_note': note,
          },
        );
      },
    );
  }

  Future<void> revoke({
    required String prestataireId,
    String? note,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'adminVerification.revoke',
      action: () async {
        await _client.rpc(
          'revoke_prestataire_verification',
          params: {
            'p_prestataire_id': prestataireId,
            'p_note': note,
          },
        );
      },
    );
  }
}

