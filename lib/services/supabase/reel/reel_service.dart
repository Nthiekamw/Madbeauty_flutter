import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
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

  /// Limite prod : galerie d’un Reel (alignée sur le trigger SQL).
  static const maxMediaPerPost = 10;

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

  Future<bool> toggleFavorite(String reelId) => SupabaseErrorHandler.run(
        operation: 'reel.toggleFavorite',
        action: () async {
          final saved = await _client.rpc(
            'toggle_reel_favorite',
            params: {'p_reel_id': reelId},
          );
          return saved as bool? ?? false;
        },
      );

  Future<ReelFeedItem?> getFeedItem(String reelId) => SupabaseErrorHandler.run(
        operation: 'reel.getFeedItem',
        action: () async {
          final rows = await _client.rpc(
            'get_reel_feed_item',
            params: {'p_reel_id': reelId},
          );
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          if (list.isEmpty) return null;
          final item = ReelFeedItem.fromJson(list.first);
          if (item.id.isEmpty || item.mediaUrl.isEmpty) return null;
          return item;
        },
      );

  Future<List<ReelFeedItem>> listFavorites({int limit = 40}) =>
      SupabaseErrorHandler.run(
        operation: 'reel.listFavorites',
        action: () async {
          final rows = await _client.rpc(
            'list_reel_favorites',
            params: {'p_limit': limit},
          );
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          return list
              .map(ReelFeedItem.fromJson)
              .where((e) => e.id.isNotEmpty && e.mediaUrl.isNotEmpty)
              .toList();
        },
      );

  Future<ReelCommentsPage> listComments({
    required String reelId,
    int limit = 30,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'reel.listComments',
        action: () async {
          final rows = await _client.rpc(
            'list_reel_comments',
            params: {
              'p_reel_id': reelId,
              'p_limit': limit,
              'p_cursor_created_at':
                  cursorCreatedAt?.toUtc().toIso8601String(),
              'p_cursor_id': cursorId,
            },
          );
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          final items = list
              .map(ReelComment.fromJson)
              .where((e) => e.id.isNotEmpty && e.body.isNotEmpty)
              .toList();
          final last = items.isEmpty ? null : items.last;
          return ReelCommentsPage(
            items: items,
            nextCursorCreatedAt: last?.createdAt,
            nextCursorId: last?.id,
          );
        },
      );

  Future<ReelComment> addComment({
    required String reelId,
    required String body,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'reel.addComment',
        action: () async {
          final rows = await _client.rpc(
            'add_reel_comment',
            params: {
              'p_reel_id': reelId,
              'p_body': body,
            },
          );
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          if (list.isEmpty) {
            throw StateError('Commentaire non créé.');
          }
          return ReelComment.fromJson(list.first);
        },
      );

  Future<void> deleteComment(String commentId) => SupabaseErrorHandler.run(
        operation: 'reel.deleteComment',
        action: () async {
          await _client.rpc(
            'delete_reel_comment',
            params: {'p_comment_id': commentId},
          );
        },
      );

  Future<List<ReelPostOwned>> listOwnPosts({required String prestataireId}) =>
      SupabaseErrorHandler.run(
        operation: 'reel.listOwnPosts',
        action: () async {
          final rows = await _client
              .from('reel_posts')
              .select('*, reel_post_media(*)')
              .eq('prestataire_id', prestataireId)
              .order('created_at', ascending: false)
              .order('sort_order', ascending: true, referencedTable: 'reel_post_media')
              .limit(100);
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          return list.map(ReelPostOwned.fromJson).toList();
        },
      );

  /// Publie un Reel avec 1 à [maxMediaPerPost] médias (photos et/ou 1 vidéo).
  Future<ReelPostOwned> publish({
    required String prestataireId,
    required List<StorageUploadFile> files,
    String? caption,
    StorageUploadProgress? onProgress,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'reel.publish',
        action: () async {
          if (files.isEmpty) {
            throw const AppFailure(DiscReel.publishNeedMedia);
          }
          if (files.length > maxMediaPerPost) {
            throw AppFailure(DiscReel.publishMediaLimit(maxMediaPerPost));
          }
          final videoCount = files.where(StorageService.isVideoFile).length;
          if (videoCount > 1) {
            throw const AppFailure(DiscReel.publishSingleVideoOnly);
          }
          if (videoCount == 1 && files.length > 1) {
            throw const AppFailure(DiscReel.publishNoMixVideoPhotos);
          }

          final urls = <String>[];
          for (var i = 0; i < files.length; i++) {
            final file = files[i];
            final url = await _storage.uploadReelMedia(
              prestataireId: prestataireId,
              file: file,
              onProgress: onProgress == null
                  ? null
                  : (p) => onProgress((i + p) / files.length),
            );
            urls.add(url);
          }

          final coverType = StorageService.isVideoFile(files.first)
              ? RealisationMediaType.video
              : RealisationMediaType.image;
          final trimmed = caption?.trim();
          String? reelId;
          try {
            final row = await _client
                .from('reel_posts')
                .insert({
                  'prestataire_id': prestataireId,
                  'media_type': coverType == RealisationMediaType.video
                      ? 'video'
                      : 'image',
                  'media_url': urls.first,
                  if (trimmed != null && trimmed.isNotEmpty) 'caption': trimmed,
                  'status': 'published',
                })
                .select()
                .single();
            reelId = row['id'] as String?;
            if (reelId == null || reelId.isEmpty) {
              throw StateError('Reel non créé.');
            }

            final mediaRows = <Map<String, dynamic>>[
              for (var i = 0; i < urls.length; i++)
                {
                  'reel_id': reelId,
                  'media_type': StorageService.isVideoFile(files[i])
                      ? 'video'
                      : 'image',
                  'media_url': urls[i],
                  'sort_order': i,
                },
            ];
            await _client.from('reel_post_media').insert(mediaRows);

            final owned = await _client
                .from('reel_posts')
                .select('*, reel_post_media(*)')
                .eq('id', reelId)
                .single();
            return ReelPostOwned.fromJson(owned);
          } catch (e) {
            if (reelId != null && reelId.isNotEmpty) {
              try {
                await _client.from('reel_posts').delete().eq('id', reelId);
              } catch (_) {}
            }
            rethrow;
          }
        },
      );

  Future<void> deletePost(String reelId) => SupabaseErrorHandler.run(
        operation: 'reel.deletePost',
        action: () async {
          await _client.from('reel_posts').delete().eq('id', reelId);
        },
      );
}
