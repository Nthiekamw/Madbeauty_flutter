import 'package:flutter/material.dart';

import '../../../core/config/share_link_config.dart';
import '../../../core/config/share_link_resolver.dart';
import '../../../core/constants/strings/discovery/disc_presta_detail.dart';
import '../../../shared/utils/native_share.dart';

/// Partage la fiche (SMS, WhatsApp, etc.) via la feuille système.
Future<NativeShareOutcome> sharePrestataireProfile({
  required BuildContext context,
  required String prestataireId,
  required String displayName,
  String? publicSlug,
}) async {
  final link = ShareLinkResolver.prestataireProfileUrl(
    prestataireId,
    publicSlug: publicSlug,
  );
  final title = displayName.trim().isEmpty ? 'MadBeauty' : displayName.trim();
  final storeLine = ShareLinkConfig.downloadShareFooter(
    hint: 'Télécharge MadBeauty :',
  );

  final buffer = StringBuffer()
    ..writeln(DiscPrestaDetail.shareMessage(title))
    ..writeln(link);
  if (storeLine != null) {
    buffer
      ..writeln()
      ..writeln(storeLine);
  }

  return NativeShare.shareText(
    context: context,
    text: buffer.toString().trim(),
    subject: title,
  );
}
