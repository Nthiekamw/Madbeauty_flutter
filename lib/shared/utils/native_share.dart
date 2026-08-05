import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Partage natif robuste (iPhone + iPad).
///
/// Sur iPad, `share_plus` exige un [ShareParams.sharePositionOrigin] non nul,
/// sinon la feuille de partage plante → « Partage impossible ».
abstract final class NativeShare {
  NativeShare._();

  /// Ancre popover depuis le widget qui déclenche le partage.
  static Rect originOf(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize && box.attached) {
      final size = box.size;
      if (size.width > 0 && size.height > 0) {
        return box.localToGlobal(Offset.zero) & size;
      }
    }
    final media = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(media.width / 2, media.height / 2),
      width: 44,
      height: 44,
    );
  }

  /// Ouvre la feuille système. Ne considère pas l’annulation comme une erreur.
  /// En cas d’échec plateforme : copie le texte dans le presse-papiers.
  static Future<NativeShareOutcome> shareText({
    required BuildContext context,
    required String text,
    String? subject,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return NativeShareOutcome.failed;
    }

    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: trimmed,
          subject: subject,
          sharePositionOrigin: originOf(context),
        ),
      );
      if (result.status == ShareResultStatus.dismissed) {
        return NativeShareOutcome.dismissed;
      }
      return NativeShareOutcome.shared;
    } on Object {
      try {
        await Clipboard.setData(ClipboardData(text: trimmed));
        return NativeShareOutcome.copiedFallback;
      } on Object {
        return NativeShareOutcome.failed;
      }
    }
  }
}

enum NativeShareOutcome {
  shared,
  dismissed,
  copiedFallback,
  failed,
}
