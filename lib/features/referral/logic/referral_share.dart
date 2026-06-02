import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/share_link_resolver.dart';
import '../../../core/constants/app_strings.dart';

Future<void> shareReferralInvite(String code) async {
  final link = ShareLinkResolver.inviteUrl(code);
  await SharePlus.instance.share(
    ShareParams(
      text: '${DiscReferral.shareMessage} $code\n$link',
      subject: DiscReferral.screenTitle,
    ),
  );
}

Future<void> copyReferralCode(String code) async {
  await Clipboard.setData(ClipboardData(text: code));
}
