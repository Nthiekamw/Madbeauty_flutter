import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/failure_mapper.dart';
import '../../../services/auth/account_deletion_service.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../auth/providers/auth_notifier.dart';

/// Demande de suppression de compte puis déconnexion.
Future<void> runAccountDeletionRequestFlow({
  required BuildContext context,
  required WidgetRef ref,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(DiscProfile.deleteAccountTitle),
      content: const Text(DiscProfile.deleteAccountBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text(CoreStrings.actionCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(DiscProfile.deleteAccountConfirm),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  try {
    await AccountDeletionService.fromEnv().requestAccountDeletion();
    await LocalCacheService.instance.setProfilePushNotificationsEnabled(false);
    await LocalCacheService.instance.setProfileGeolocationEnabled(false);
    await ref.read(authNotifierProvider.notifier).signOut();
    if (context.mounted) {
      AppSnackBar.show(
        context,
        message: DiscProfile.deleteAccountDone,
        kind: AppSnackKind.success,
      );
    }
  } catch (error) {
    if (!context.mounted) return;
    final message = error is AppFailure
        ? error.message
        : FailureMapper.fromUnknown(error).message;
    AppSnackBar.show(
      context,
      message: message.isNotEmpty ? message : DiscProfile.deleteAccountErr,
      kind: AppSnackKind.error,
    );
  }
}
