import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../auth/providers/auth_notifier.dart';
import '../providers/client_prestataire_likes_provider.dart';

/// Bascule le like client → prestataire (connexion, feedback, erreurs).
Future<void> togglePrestataireLike({
  required BuildContext context,
  required WidgetRef ref,
  required String prestataireId,
}) async {
  final user = switch (ref.read(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (user == null) {
    if (!context.mounted) return;
    AppSnackBar.show(context, message: DiscLike.loginRequired);
    context.pushLogin();
    return;
  }

  final wasLiked = ref.read(isPrestataireLikedProvider(prestataireId));

  try {
    await ref
        .read(clientLikedPrestataireIdsProvider.notifier)
        .toggle(prestataireId);
    if (!context.mounted) return;
    AppSnackBar.show(
      context,
      message: wasLiked ? DiscLike.removedFeedback : DiscLike.addedFeedback,
    );
  } catch (_) {
    if (!context.mounted) return;
    AppSnackBar.show(context, message: DiscLike.toggleError);
  }
}
