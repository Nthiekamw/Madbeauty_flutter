import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../providers/pwa_install_provider.dart';

BuildContext? _pwaOverlayContext(WidgetRef ref, BuildContext fallback) {
  final fromRouter =
      ref.read(goRouterProvider).routerDelegate.navigatorKey.currentContext;
  if (fromRouter != null && fromRouter.mounted) return fromRouter;
  return fallback.mounted ? fallback : null;
}

/// Lance l’installation PWA ou affiche les instructions iOS.
Future<void> handlePwaInstallTap(
  BuildContext context,
  WidgetRef ref,
  PwaInstallState state,
) async {
  final overlayContext = _pwaOverlayContext(ref, context);
  if (overlayContext == null) return;

  if (state.showIosInstructions) {
    await showDialog<void>(
      context: overlayContext,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscPwa.installIosDialogTitle),
        content: const Text(DiscPwa.installIosDialogBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(DiscPwa.installIosDialogAction),
          ),
        ],
      ),
    );
    return;
  }

  final accepted = await ref.read(pwaInstallProvider.notifier).install();
  if (overlayContext.mounted && accepted) {
    AppSnackBar.show(overlayContext, message: DiscPwa.installSuccess);
  }
}
