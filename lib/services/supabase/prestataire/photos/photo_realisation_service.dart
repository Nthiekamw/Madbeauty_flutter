import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../storage/storage_service.dart';

class PhotoRealisationService {
  PhotoRealisationService(this._client, {StorageService? storageService})
    : _storageService = storageService;

  final SupabaseClient _client;
  final StorageService? _storageService;

  Future<List<PhotoRealisation>> getByPrestataire(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'photoRealisation.getByPrestataire',
        action: () async {
          final response = await _client
              .from('photos_realisation')
              .select()
              .eq('prestataire_id', prestataireId)
              .order('created_at', ascending: false);
          return (response as List<dynamic>)
              .map(
                (row) => PhotoRealisation.fromJson(row as Map<String, dynamic>),
              )
              .toList();
        },
      );

  Future<PhotoRealisation> uploadAndCreate({
    required String prestataireId,
    required StorageUploadFile file,
    String? caption,
    String? categorieId,
    StorageUploadProgress? onProgress,
  }) => SupabaseErrorHandler.run(
    operation: 'photoRealisation.uploadAndCreate',
    action: () async {
      final storageService = _storageService;
      if (storageService == null) {
        throw StateError('StorageService non configuré.');
      }

      final url = await storageService.uploadRealisation(
        prestataireId: prestataireId,
        file: file,
        onProgress: onProgress,
      );
      return create(
        prestataireId: prestataireId,
        url: url,
        caption: caption,
        categorieId: categorieId,
      );
    },
  );

  Future<PhotoRealisation> create({
    required String prestataireId,
    required String url,
    String? caption,
    String? categorieId,
  }) => SupabaseErrorHandler.run(
    operation: 'photoRealisation.create',
    action: () async {
      final response = await _client
          .from('photos_realisation')
          .insert({
            'prestataire_id': prestataireId,
            'url': url,
            if (caption != null && caption.trim().isNotEmpty)
              'caption': caption.trim(),
            if (categorieId != null && categorieId.trim().isNotEmpty)
              'categorie_id': categorieId.trim(),
          })
          .select()
          .single();
      return PhotoRealisation.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    },
  );

  Future<void> delete(String id) => SupabaseErrorHandler.run(
    operation: 'photoRealisation.delete',
    action: () async {
      await _client.from('photos_realisation').delete().eq('id', id);
    },
  );
}

