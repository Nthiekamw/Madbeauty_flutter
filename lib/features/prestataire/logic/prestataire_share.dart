import 'package:share_plus/share_plus.dart';

import '../../../core/config/share_link_resolver.dart';
import '../../../core/constants/strings/discovery/disc_presta_detail.dart';

/// Partage la fiche (SMS, WhatsApp, etc.) via [SharePlus].
Future<void> sharePrestataireProfile({
  required String prestataireId,
  required String displayName,
}) async {
  final link = ShareLinkResolver.prestataireProfileUrl(prestataireId);
  final title = displayName.trim().isEmpty ? 'MadBeauty' : displayName.trim();

  await SharePlus.instance.share(
    ShareParams(
      text: '${DiscPrestaDetail.shareMessage(title)}\n$link',
      subject: title,
    ),
  );
}

