import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../core/models/domain/reel/reel_feed_item.dart';
import '../storage/storage_service.dart';
import '../supabase_service.dart';

class ReelService {
  ReelService(this._client, {StorageService? storage})
      : _storage = storage ?? StorageService(_client);

  final SupabaseClient _client;
  final StorageService _storage;

  factory ReelService.fromEnv() => ReelService(SupabaseService.client);

  Future<ReelFeedPage> listFeed({
    int limit = 20,
    double? cursorScore,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'reel.listFeed',
        action: () async {
          final rows = await _client.rpc(
            'list_reel_feed',
            params: {
              'p_limit': limit,
              'p_cursor_score': cursorScore,
              'p_cursor_created_at': cursorCreatedAt?.toUtc().toIso8601String(),
              'p_cursor_id': cursorId,
            },
          );
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          final items = list
              .map(ReelFeedItem.fromJson)
              .where((e) => e.id.isNotEmpty && e.mediaUrl.isNotEmpty)
              .toList();
          final last = items.isEmpty ? null : items.last;
          return ReelFeedPage(
            items: items,
            nextCursorScore: last?.score,
            nextCursorCreatedAt: last?.createdAt,
            nextCursorId: last?.id,
          );
        },
      );

  Future<void> recordView(String reelId) => SupabaseErrorHandler.run(
        operation: 'reel.recordView',
        action: () async {
          await _client.rpc('record_reel_view', params: {'p_reel_id': reelId});
        },
      );

  Future<bool> toggleLike(String reelId) => SupabaseErrorHandler.run(
        operation: 'reel.toggleLike',
        action: () async {
          final liked = await _client.rpc(
            'toggle_reel_like',
            params: {'p_reel_id': reelId},
          );
          return liked as bool? ?? false;
        },
      );

  Future<List<ReelPostOwned>> listOwnPosts({required String prestataireId}) =>
      SupabaseErrorHandler.run(
        operation: 'reel.listOwnPosts',
        action: () async {
          final rows = await _client
              .from('reel_posts')
              .select()
              .eq('prestataire_id', prestataireId)
              .order('created_at', ascending: false)
              .limit(100);
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          return list.map(ReelPostOwned.fromJson).toList();
        },
      );

  Future<ReelPostOwned> publish({
    required String prestataireId,
    required StorageUploadFile file,
    String? caption,
    StorageUploadProgress? onProgress,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'reel.publish',
        action: () async {
          final url = await _storage.uploadReelMedia(
            prestataireId: prestataireId,
            file: file,
            onProgress: onProgress,
          );
          final mediaType = file.isVideo
              ? RealisationMediaType.video
              : RealisationMediaType.image;
          final trimmed = caption?.trim();
          final row = await _client
              .from('reel_posts')
              .insert({
                'prestataire_id': prestataireId,
                'media_type': mediaType == RealisationMediaType.video
                    ? 'video'
                    : 'image',
                'media_url': url,
                if (trimmed != null && trimmed.isNotEmpty) 'caption': trimmed,
                'status': 'published',
              })
              .select()
              .single();
          return ReelPostOwned.fromJson(row);
        },
      );

  Future<void> deletePost(String reelId) => SupabaseErrorHandler.run(
        operation: 'reel.deletePost',
        action: () async {
          await _client.from('reel_posts').delete().eq('id', reelId);
        },
      );
}
