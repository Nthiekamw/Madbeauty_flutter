import 'package:share_plus/share_plus.dart';

import '../../../core/config/share_link_resolver.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/reel/reel_feed_item.dart';

/// Partage un Reel (SMS, WhatsApp, etc.) via [SharePlus].
Future<void> shareReelPost(ReelFeedItem item) async {
  final link = ShareLinkResolver.reelUrl(item.id);
  final salon = item.salonName.trim().isEmpty ? 'MadBeauty' : item.salonName.trim();
  final caption = item.caption?.trim();

  await SharePlus.instance.share(
    ShareParams(
      text: '${DiscReel.shareMessage(salon, caption)}\n$link',
      subject: DiscReel.shareSubject(salon),
    ),
  );
}
