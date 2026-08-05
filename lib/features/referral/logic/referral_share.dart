import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/config/share_link_config.dart';
import '../../../core/config/share_link_resolver.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/utils/native_share.dart';

Future<NativeShareOutcome> shareReferralInvite(
  BuildContext context,
  String code,
) async {
  final link = ShareLinkResolver.inviteUrl(code);
  final storeLine = ShareLinkConfig.downloadShareFooter(
    hint: 'Télécharge MadBeauty :',
  );
  final buffer = StringBuffer()
    ..writeln('${DiscReferral.shareMessage} $code')
    ..writeln(link);
  if (storeLine != null) {
    buffer
      ..writeln()
      ..writeln(storeLine);
  }

  return NativeShare.shareText(
    context: context,
    text: buffer.toString().trim(),
    subject: DiscReferral.screenTitle,
  );
}

Future<void> copyReferralCode(String code) async {
  await Clipboard.setData(ClipboardData(text: code));
}
