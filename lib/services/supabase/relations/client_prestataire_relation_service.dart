import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

/// Relations client ↔ salon (VIP).
class ClientPrestataireRelationService {
  ClientPrestataireRelationService(this._client);

  final SupabaseClient _client;

  Future<bool> isClientVipAtPrestataire({
    required String clientId,
    required String prestataireId,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'clientPrestaRelation.isVip',
      action: () async {
        final raw = await _client.rpc(
          'is_client_vip_at_prestataire',
          params: {
            'p_client_id': clientId,
            'p_prestataire_id': prestataireId,
          },
        );
        return raw == true;
      },
    );
  }

  Future<bool> isCurrentClientVipAtPrestataire(String prestataireId) {
    return SupabaseErrorHandler.run(
      operation: 'clientPrestaRelation.isCurrentVip',
      action: () async {
        final uid = _client.auth.currentUser?.id;
        if (uid == null) return false;
        final row = await _client
            .from('client_profiles')
            .select('id')
            .eq('user_id', uid)
            .maybeSingle();
        final clientId = row?['id'] as String?;
        if (clientId == null) return false;
        return isClientVipAtPrestataire(
          clientId: clientId,
          prestataireId: prestataireId,
        );
      },
    );
  }
}
