import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/reviews/avis.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';

class AvisService {
  AvisService(this._client);

  final SupabaseClient _client;

  Future<List<Avis>> getByPrestataireId(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'avis.getByPrestataireId',
        action: () async {
          final response = await _client
              .from('avis')
              .select()
              .eq('prestataire_id', prestataireId)
              .order('created_at', ascending: false);

          return (response as List<dynamic>)
              .map(
                (raw) => SupabaseDomainCodec.avis(
                  Map<String, dynamic>.from(raw as Map),
                ),
              )
              .toList();
        },
      );
}
