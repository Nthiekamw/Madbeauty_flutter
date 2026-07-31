import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/catalog/realisation_media_type.dart';
import 'package:madbeauty/core/models/domain/reel/reel_feed_item.dart';

void main() {
  test('ReelFeedItem.fromJson parse media + score', () {
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
    expect(item.caption, 'Soft glam');
    expect(item.score, 12.5);
    expect(item.likedByMe, isTrue);
    expect(item.commentsCount, 2);
    expect(item.salonName, 'Studio Mad');
  });
}
