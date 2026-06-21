import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

/// Like client → prestataire (une ligne par paire).
class PrestataireLikeRecord {
  const PrestataireLikeRecord({
    required this.clientId,
    required this.prestataireId,
    required this.createdAt,
    this.clientDisplayName,
  });

  final String clientId;
  final String prestataireId;
  final DateTime createdAt;
  final String? clientDisplayName;
}

class PrestataireLikeService {
  PrestataireLikeService(this._client);

  final SupabaseClient _client;

  Future<String?> currentPrestataireProfileId() => SupabaseErrorHandler.run(
        operation: 'prestataireLike.currentPrestataireProfileId',
        action: () async {
          final userId = _client.auth.currentUser?.id;
          if (userId == null) return null;
          final row = await _client
              .from('prestataire_profiles')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();
          return row?['id'] as String?;
        },
      );

  Future<int> countForPrestataire(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'prestataireLike.count',
        action: () async {
          final row = await _client
              .from('prestataire_profiles')
              .select('likes_count')
              .eq('id', prestataireId)
              .maybeSingle();
          return (row?['likes_count'] as num?)?.toInt() ?? 0;
        },
      );

  Future<List<String>> listLikedPrestataireIds(String clientId) =>
      SupabaseErrorHandler.run(
        operation: 'prestataireLike.listIds',
        action: () async {
          final response = await _client
              .from('prestataire_likes')
              .select('prestataire_id')
              .eq('client_id', clientId)
              .order('created_at', ascending: false);
          return (response as List<dynamic>)
              .map((row) => (row as Map)['prestataire_id'] as String)
              .toList();
        },
      );

  Future<List<PrestataireLikeRecord>> listRecentForPrestataire(
    String prestataireId, {
    DateTime? since,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'prestataireLike.listRecentForPrestataire',
        action: () async {
          var filter = _client
              .from('prestataire_likes')
              .select(
                'client_id, prestataire_id, created_at, client_display_name',
              )
              .eq('prestataire_id', prestataireId);

          if (since != null) {
            filter = filter.gte(
              'created_at',
              since.toUtc().toIso8601String(),
            );
          }

          final response = await filter
              .order('created_at', ascending: false)
              .limit(25);
          return [
            for (final raw in response as List<dynamic>)
              PrestataireLikeRecord(
                clientId: (raw as Map)['client_id'] as String,
                prestataireId: raw['prestataire_id'] as String,
                createdAt: DateTime.parse(raw['created_at'] as String),
                clientDisplayName: raw['client_display_name'] as String?,
              ),
          ];
        },
      );

  Future<void> like({
    required String clientId,
    required String prestataireId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'prestataireLike.like',
        action: () async {
          try {
            await _client.from('prestataire_likes').insert({
              'client_id': clientId,
              'prestataire_id': prestataireId,
            });
          } on PostgrestException catch (e) {
            if (e.code == '23505') return;
            rethrow;
          }
        },
      );

  Future<void> unlike({
    required String clientId,
    required String prestataireId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'prestataireLike.unlike',
        action: () async {
          await _client
              .from('prestataire_likes')
              .delete()
              .eq('client_id', clientId)
              .eq('prestataire_id', prestataireId);
        },
      );
}
