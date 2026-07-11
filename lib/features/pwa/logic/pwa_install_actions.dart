import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../providers/pwa_install_provider.dart';

/// Lance l’installation PWA ou affiche les instructions iOS.
Future<void> handlePwaInstallTap(
  BuildContext context,
  WidgetRef ref,
  PwaInstallState state,
) async {
  if (state.showIosInstructions) {
    await showDialog<void>(
      context: context,
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
  if (!context.mounted) return;
  if (accepted) {
    AppSnackBar.show(context, message: DiscPwa.installSuccess);
  }
}
