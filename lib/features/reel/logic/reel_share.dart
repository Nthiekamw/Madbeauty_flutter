import 'package:flutter/material.dart';

import '../../../core/config/share_link_config.dart';
import '../../../core/config/share_link_resolver.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/reel/reel_feed_item.dart';
import '../../../shared/utils/native_share.dart';

/// Partage un Reel (SMS, WhatsApp, etc.) via la feuille système.
Future<NativeShareOutcome> shareReelPost(
  BuildContext context,
  ReelFeedItem item,
) async {
  final link = ShareLinkResolver.reelUrl(item.id);
  final salon =
      item.salonName.trim().isEmpty ? 'MadBeauty' : item.salonName.trim();
  final caption = item.caption?.trim();
  final storeLine = ShareLinkConfig.downloadShareFooter(
    hint: DiscReel.shareDownloadHint,
  );

  final buffer = StringBuffer()
    ..writeln(DiscReel.shareMessage(salon, caption))
    ..writeln(link);
  if (storeLine != null) {
    buffer
      ..writeln()
      ..writeln(storeLine);
  }

  return NativeShare.shareText(
    context: context,
    text: buffer.toString().trim(),
    subject: DiscReel.shareSubject(salon),
  );
}
