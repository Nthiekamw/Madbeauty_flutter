import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_realisation_photo_summary.dart';
import '../storage/storage_service.dart';
import '../supabase_service.dart';

/// Actions de modération sur une photo de réalisation.
enum AdminRealisationPhotoAction {
  remove('remove'),
  flagObscene('flag_obscene'),
  warn('warn'),
  ban('ban');

  const AdminRealisationPhotoAction(this.wireValue);
  final String wireValue;
}

class AdminRealisationPhotosService {
  AdminRealisationPhotosService(
    this._client, {
    StorageService? storageService,
  }) : _storageService = storageService;

  final SupabaseClient _client;
  final StorageService? _storageService;

  factory AdminRealisationPhotosService.fromEnv() =>
      AdminRealisationPhotosService(
        SupabaseService.client,
        storageService: StorageService(SupabaseService.client),
      );

  Future<List<AdminRealisationPhotoSummary>> listPhotos({
    int limit = 60,
    int offset = 0,
    String? search,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminRealisationPhotos.list',
      action: () async {
        final rows = await _client.rpc(
          'admin_list_realisation_photos',
          params: {
            'p_limit': limit,
            'p_offset': offset,
            if (search != null && search.trim().isNotEmpty)
              'p_search': search.trim(),
          },
        );
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(_mapRow).toList();
      },
    );
  }

  Future<void> moderatePhoto({
    required String photoId,
    required AdminRealisationPhotoAction action,
    String? note,
    String? banReason,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'adminRealisationPhotos.moderate',
      action: () async {
        final result = await _client.rpc(
          'admin_moderate_realisation_photo',
          params: {
            'p_photo_id': photoId,
            'p_action': action.wireValue,
            'p_note': note,
            'p_ban_reason': banReason,
          },
        );

        if (result is! Map) return;
        final map = Map<String, dynamic>.from(result);
        final removed = map['removed'] as bool? ?? false;
        final photoUrl = map['photo_url'] as String?;
        if (!removed || photoUrl == null || photoUrl.isEmpty) return;

        final storage = _storageService;
        if (storage == null) return;
        try {
          await storage.deleteFile(photoUrl);
        } catch (_) {
          // La ligne DB est déjà supprimée ; l’objet storage peut être nettoyé plus tard.
        }
      },
    );
  }

  AdminRealisationPhotoSummary _mapRow(Map<String, dynamic> row) {
    return AdminRealisationPhotoSummary(
      id: row['id'] as String? ?? '',
      prestataireId: row['prestataire_id'] as String? ?? '',
      prestataireUserId: row['prestataire_user_id'] as String? ?? '',
      prestataireLabel: row['prestataire_label'] as String? ?? 'Prestataire',
      ownerEmail: row['owner_email'] as String?,
      url: row['url'] as String? ?? '',
      caption: row['caption'] as String?,
      mediaType: row['media_type'] as String? ?? 'image',
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
