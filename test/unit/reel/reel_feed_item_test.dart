import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/catalog/realisation_media_type.dart';
import 'package:madbeauty/core/models/domain/reel/reel_feed_item.dart';

void main() {
  test('ReelFeedItem.fromJson parse media + score (legacy cover)', () {
    final item = ReelFeedItem.fromJson({
      'id': 'r1',
      'prestataire_id': 'p1',
      'media_type': 'video',
      'media_url': 'https://example.com/v.mp4',
      'caption': ' Soft glam ',
      'likes_count': 3,
      'comments_count': 2,
      'views_count': 10,
      'created_at': '2026-07-25T10:00:00Z',
      'score': 12.5,
      'liked_by_me': true,
      'salon_name': 'Studio Mad',
      'avatar_url': null,
      'ville': 'Paris',
    });

    expect(item.id, 'r1');
    expect(item.mediaType, RealisationMediaType.video);
    expect(item.mediaUrl, 'https://example.com/v.mp4');
    expect(item.media, hasLength(1));
    expect(item.caption, 'Soft glam');
    expect(item.score, 12.5);
    expect(item.likedByMe, isTrue);
    expect(item.savedByMe, isFalse);
    expect(item.commentsCount, 2);
    expect(item.salonName, 'Studio Mad');
  });

  test('ReelFeedItem.fromJson parse galerie media jsonb', () {
    final item = ReelFeedItem.fromJson({
      'id': 'r2',
      'prestataire_id': 'p1',
      'media_type': 'image',
      'media_url': 'https://example.com/a.jpg',
      'media': [
        {
          'media_type': 'image',
          'media_url': 'https://example.com/b.jpg',
          'sort_order': 1,
        },
        {
          'media_type': 'image',
          'media_url': 'https://example.com/a.jpg',
          'sort_order': 0,
        },
      ],
      'likes_count': 0,
      'comments_count': 0,
      'views_count': 0,
      'created_at': '2026-08-05T10:00:00Z',
      'score': 1,
      'liked_by_me': false,
      'saved_by_me': true,
      'salon_name': 'Glow',
    });

    expect(item.hasMultipleMedia, isTrue);
    expect(item.savedByMe, isTrue);
    expect(item.media, hasLength(2));
    expect(item.media.first.mediaUrl, 'https://example.com/a.jpg');
    expect(item.media.last.mediaUrl, 'https://example.com/b.jpg');
  });

  test('ReelPostOwned.fromJson parse reel_post_media embed', () {
    final post = ReelPostOwned.fromJson({
      'id': 'r3',
      'prestataire_id': 'p1',
      'media_type': 'image',
      'media_url': 'https://example.com/1.jpg',
      'status': 'published',
      'likes_count': 1,
      'comments_count': 0,
      'views_count': 2,
      'created_at': '2026-08-05T10:00:00Z',
      'reel_post_media': [
        {
          'media_type': 'image',
          'media_url': 'https://example.com/1.jpg',
          'sort_order': 0,
        },
        {
          'media_type': 'image',
          'media_url': 'https://example.com/2.jpg',
          'sort_order': 1,
        },
      ],
    });

    expect(post.media, hasLength(2));
    expect(post.hasMultipleMedia, isTrue);
    expect(post.mediaUrl, 'https://example.com/1.jpg');
  });
}
