import '../catalog/realisation_media_type.dart';

/// Un slide média d’un Reel (photo ou vidéo).
class ReelMediaItem {
  const ReelMediaItem({
    required this.mediaType,
    required this.mediaUrl,
    this.sortOrder = 0,
  });

  final RealisationMediaType mediaType;
  final String mediaUrl;
  final int sortOrder;

  bool get isVideo => mediaType == RealisationMediaType.video;

  factory ReelMediaItem.fromJson(Map<String, dynamic> row) {
    final mediaRaw = (row['media_type'] as String?)?.trim() ?? 'image';
    return ReelMediaItem(
      mediaType: mediaRaw == 'video'
          ? RealisationMediaType.video
          : RealisationMediaType.image,
      mediaUrl: (row['media_url'] as String?)?.trim() ?? '',
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  static List<ReelMediaItem> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    final items = <ReelMediaItem>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final item = ReelMediaItem.fromJson(Map<String, dynamic>.from(entry));
      if (item.mediaUrl.isEmpty) continue;
      items.add(item);
    }
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }
}

/// Post Reel renvoyé par `list_reel_feed` (feed client).
class ReelFeedItem {
  const ReelFeedItem({
    required this.id,
    required this.prestataireId,
    required this.media,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.createdAt,
    required this.score,
    required this.likedByMe,
    required this.salonName,
    this.savedByMe = false,
    this.caption,
    this.avatarUrl,
    this.ville,
  });

  final String id;
  final String prestataireId;
  final List<ReelMediaItem> media;
  final String? caption;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final DateTime createdAt;
  final double score;
  final bool likedByMe;
  final bool savedByMe;
  final String salonName;
  final String? avatarUrl;
  final String? ville;

  /// Cover (1er média) — compat UI mono-média.
  ReelMediaItem? get cover => media.isEmpty ? null : media.first;

  RealisationMediaType get mediaType =>
      cover?.mediaType ?? RealisationMediaType.image;

  String get mediaUrl => cover?.mediaUrl ?? '';

  bool get hasMultipleMedia => media.length > 1;

  ReelFeedItem copyWith({
    int? likesCount,
    int? commentsCount,
    bool? likedByMe,
    bool? savedByMe,
  }) {
    return ReelFeedItem(
      id: id,
      prestataireId: prestataireId,
      media: media,
      caption: caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount,
      createdAt: createdAt,
      score: score,
      likedByMe: likedByMe ?? this.likedByMe,
      savedByMe: savedByMe ?? this.savedByMe,
      salonName: salonName,
      avatarUrl: avatarUrl,
      ville: ville,
    );
  }

  factory ReelFeedItem.fromJson(Map<String, dynamic> row) {
    var media = ReelMediaItem.listFromJson(row['media']);
    if (media.isEmpty) {
      final url = (row['media_url'] as String?)?.trim() ?? '';
      if (url.isNotEmpty) {
        final mediaRaw = (row['media_type'] as String?)?.trim() ?? 'image';
        media = [
          ReelMediaItem(
            mediaType: mediaRaw == 'video'
                ? RealisationMediaType.video
                : RealisationMediaType.image,
            mediaUrl: url,
          ),
        ];
      }
    }
    return ReelFeedItem(
      id: row['id'] as String? ?? '',
      prestataireId: row['prestataire_id'] as String? ?? '',
      media: media,
      caption: (row['caption'] as String?)?.trim(),
      likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (row['comments_count'] as num?)?.toInt() ?? 0,
      viewsCount: (row['views_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      score: (row['score'] as num?)?.toDouble() ?? 0,
      likedByMe: row['liked_by_me'] as bool? ?? false,
      savedByMe: row['saved_by_me'] as bool? ?? false,
      salonName: (row['salon_name'] as String?)?.trim().isNotEmpty == true
          ? (row['salon_name'] as String).trim()
          : 'Salon',
      avatarUrl: row['avatar_url'] as String?,
      ville: row['ville'] as String?,
    );
  }
}

/// Commentaire Reel (`list_reel_comments` / `add_reel_comment`).
class ReelComment {
  const ReelComment({
    required this.id,
    required this.reelId,
    required this.clientId,
    required this.body,
    required this.createdAt,
    required this.authorName,
    required this.isMine,
    this.authorAvatarUrl,
  });

  final String id;
  final String reelId;
  final String clientId;
  final String body;
  final DateTime createdAt;
  final String authorName;
  final String? authorAvatarUrl;
  final bool isMine;

  factory ReelComment.fromJson(Map<String, dynamic> row) {
    return ReelComment(
      id: row['id'] as String? ?? '',
      reelId: row['reel_id'] as String? ?? '',
      clientId: row['client_id'] as String? ?? '',
      body: (row['body'] as String?)?.trim() ?? '',
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      authorName: (row['author_name'] as String?)?.trim().isNotEmpty == true
          ? (row['author_name'] as String).trim()
          : 'Cliente',
      authorAvatarUrl: row['author_avatar_url'] as String?,
      isMine: row['is_mine'] as bool? ?? false,
    );
  }
}

class ReelCommentsPage {
  const ReelCommentsPage({
    required this.items,
    this.nextCursorCreatedAt,
    this.nextCursorId,
  });

  final List<ReelComment> items;
  final DateTime? nextCursorCreatedAt;
  final String? nextCursorId;

  bool get hasMore =>
      items.isNotEmpty &&
      nextCursorCreatedAt != null &&
      nextCursorId != null;
}

/// Post Reel côté gestion prestataire (table `reel_posts` + galerie).
class ReelPostOwned {
  const ReelPostOwned({
    required this.id,
    required this.prestataireId,
    required this.media,
    required this.status,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.createdAt,
    this.caption,
  });

  final String id;
  final String prestataireId;
  final List<ReelMediaItem> media;
  final String? caption;
  final String status;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final DateTime createdAt;

  ReelMediaItem? get cover => media.isEmpty ? null : media.first;

  RealisationMediaType get mediaType =>
      cover?.mediaType ?? RealisationMediaType.image;

  String get mediaUrl => cover?.mediaUrl ?? '';

  bool get hasMultipleMedia => media.length > 1;

  factory ReelPostOwned.fromJson(Map<String, dynamic> row) {
    var media = ReelMediaItem.listFromJson(row['reel_post_media']);
    if (media.isEmpty) {
      media = ReelMediaItem.listFromJson(row['media']);
    }
    if (media.isEmpty) {
      final url = (row['media_url'] as String?)?.trim() ?? '';
      if (url.isNotEmpty) {
        final mediaRaw = (row['media_type'] as String?)?.trim() ?? 'image';
        media = [
          ReelMediaItem(
            mediaType: mediaRaw == 'video'
                ? RealisationMediaType.video
                : RealisationMediaType.image,
            mediaUrl: url,
          ),
        ];
      }
    }
    return ReelPostOwned(
      id: row['id'] as String? ?? '',
      prestataireId: row['prestataire_id'] as String? ?? '',
      media: media,
      caption: (row['caption'] as String?)?.trim(),
      status: row['status'] as String? ?? 'published',
      likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (row['comments_count'] as num?)?.toInt() ?? 0,
      viewsCount: (row['views_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class ReelFeedPage {
  const ReelFeedPage({
    required this.items,
    this.nextCursorScore,
    this.nextCursorCreatedAt,
    this.nextCursorId,
  });

  final List<ReelFeedItem> items;
  final double? nextCursorScore;
  final DateTime? nextCursorCreatedAt;
  final String? nextCursorId;

  bool get hasMore =>
      items.isNotEmpty &&
      nextCursorScore != null &&
      nextCursorCreatedAt != null &&
      nextCursorId != null;
}
