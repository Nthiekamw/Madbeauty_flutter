import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/categorie_suggestion.dart';

class CategorieSuggestionService {
  CategorieSuggestionService(this._client);

  final SupabaseClient _client;

  Future<List<CategorieSuggestion>> getByPrestataire(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'categorieSuggestion.getByPrestataire',
        action: () async {
          final response = await _client
              .from('suggestions_categorie')
              .select()
              .eq('prestataire_id', prestataireId)
              .order('created_at', ascending: false);
          return (response as List<dynamic>)
              .map(
                (row) =>
                    CategorieSuggestion.fromJson(row as Map<String, dynamic>),
              )
              .toList();
        },
      );

  Future<void> replaceForPrestataire({
    required String prestataireId,
    String? nom,
    String? description,
  }) => SupabaseErrorHandler.run(
    operation: 'categorieSuggestion.replaceForPrestataire',
    action: () async {
      await _client
          .from('suggestions_categorie')
          .delete()
          .eq('prestataire_id', prestataireId);

      final n = nom?.trim() ?? '';
      if (n.isEmpty) return;

      await _client.from('suggestions_categorie').insert({
        'prestataire_id': prestataireId,
        'nom': n,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      });
    },
  );
}
