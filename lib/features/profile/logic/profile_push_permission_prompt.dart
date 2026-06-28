import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../firebase_runtime_helpers.dart';
import '../../../services/permissions/permissions_providers.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../providers/profile_preferences_provider.dart';

/// Demande l’activation des notifications si elles sont coupées (app ou système).
Future<void> promptPushPermissionIfNeeded(
  BuildContext context,
  WidgetRef ref,
) async {
  if (!isFirebaseConfiguredForPush()) return;

  await ref.read(profilePreferencesProvider.notifier).refreshFromSystem();
  if (!context.mounted) return;

  final permissions = ref.read(appPermissionsServiceProvider);
  final osGranted = await permissions.areNotificationsGranted();
  final prefs = ref.read(profilePreferencesProvider);

  if (osGranted && prefs.pushNotificationsEnabled) return;
  if (!context.mounted) return;

  final enable = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(DiscProfile.prefPushPromptTitle),
      content: const Text(DiscProfile.prefPushPromptBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text(DiscProfile.prefPushPromptLater),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(DiscProfile.prefPushPromptEnable),
        ),
      ],
    ),
  );

  if (enable != true || !context.mounted) return;

  final ok = await ref
      .read(profilePreferencesProvider.notifier)
      .setPushNotifications(true);
  if (!context.mounted) return;

  if (ok) {
    AppSnackBar.show(context, message: DiscProfile.prefPushEnabled);
    return;
  }

  AppSnackBar.show(
    context,
    message: DiscProfile.prefPushDenied,
    kind: AppSnackKind.warning,
  );

  final openSettings = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(DiscProfile.prefPush),
      content: const Text(DiscProfile.prefPushDenied),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text(CoreStrings.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(DiscProfile.prefOpenSettings),
        ),
      ],
    ),
  );

  if (openSettings == true && context.mounted) {
    await ref.read(appPermissionsServiceProvider).openSystemSettings();
  }
}
