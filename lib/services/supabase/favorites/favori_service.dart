import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

class FavoriService {
  FavoriService(this._client);

  final SupabaseClient _client;

  Future<List<String>> listPrestataireIds(String clientId) =>
      SupabaseErrorHandler.run(
        operation: 'favori.listPrestataireIds',
        action: () async {
          final response = await _client
              .from('favoris')
              .select('prestataire_id')
              .eq('client_id', clientId)
              .order('created_at', ascending: false);

          return (response as List<dynamic>)
              .map((row) => (row as Map)['prestataire_id'] as String)
              .toList();
        },
      );

  Future<int> countForClient(String clientId) => SupabaseErrorHandler.run(
        operation: 'favori.countForClient',
        action: () async {
          final response = await _client
              .from('favoris')
              .select('prestataire_id')
              .eq('client_id', clientId);
          return (response as List<dynamic>).length;
        },
      );

  Future<void> add({
    required String clientId,
    required String prestataireId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'favori.add',
        action: () async {
          await _client.from('favoris').insert({
            'client_id': clientId,
            'prestataire_id': prestataireId,
          });
        },
      );

  Future<void> remove({
    required String clientId,
    required String prestataireId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'favori.remove',
        action: () async {
          await _client
              .from('favoris')
              .delete()
              .eq('client_id', clientId)
              .eq('prestataire_id', prestataireId);
        },
      );
}

