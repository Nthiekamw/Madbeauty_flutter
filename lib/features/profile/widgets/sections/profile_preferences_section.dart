import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../firebase_runtime_helpers.dart';
import '../../../../services/auth/biometric_auth_providers.dart';
import '../../../../services/auth/biometric_auth_service.dart';
import '../../../../services/permissions/permissions_providers.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../providers/profile_preferences_provider.dart';
import '../layout/profile_section_title.dart';

class ProfilePreferencesSection extends ConsumerStatefulWidget {
  const ProfilePreferencesSection({super.key});

  @override
  ConsumerState<ProfilePreferencesSection> createState() =>
      _ProfilePreferencesSectionState();
}

class _ProfilePreferencesSectionState
    extends ConsumerState<ProfilePreferencesSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        ref.read(profilePreferencesProvider.notifier).refreshFromSystem(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(profilePreferencesProvider);
    final biometricAsync = ref.watch(biometricAvailabilityProvider);
    final nativePush = isFirebaseConfiguredForPush();
    final pushSubtitle = nativePush
        ? (prefs.pushNotificationsEnabled
            ? DiscProfile.prefPushHint
            : DiscProfile.prefPushInactiveHint)
        : (prefs.pushNotificationsEnabled
            ? DiscProfile.prefPushWebHint
            : DiscProfile.prefPushWebInactiveHint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(
          title: DiscProfile.sectionPreferences,
          icon: Icons.tune_rounded,
        ),
        DiscoverySurfaceCard(
          child: Column(
            children: [
              _PreferenceToggle(
                icon: Icons.notifications_active_outlined,
                title: DiscProfile.prefPush,
                subtitle: pushSubtitle,
                value: prefs.pushNotificationsEnabled,
                onChanged: (value) => _onPushChanged(context, ref, value),
              ),
              if (!nativePush) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(
                    DiscProfile.prefPushWebFootnote,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.85),
                          height: 1.35,
                        ),
                  ),
                ),
              ],
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.1,
                ),
              ),
              biometricAsync.when(
                data: (availability) {
                  if (!availability.isUsable) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _PreferenceToggle(
                        icon: _biometricIcon(availability),
                        title: _biometricTitle(availability),
                        subtitle: prefs.biometricUnlockEnabled
                            ? DiscProfile.prefBiometricHint
                            : DiscProfile.prefBiometricInactiveHint,
                        value: prefs.biometricUnlockEnabled,
                        onChanged: (value) =>
                            _onBiometricChanged(context, ref, value),
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Theme.of(context).colorScheme.outline.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              _PreferenceToggle(
                icon: Icons.my_location_rounded,
                title: DiscProfile.prefLocation,
                subtitle: DiscProfile.prefLocationHint,
                value: prefs.geolocationEnabled,
                onChanged: (value) => _onGeoChanged(context, ref, value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onPushChanged(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final ok = await ref
        .read(profilePreferencesProvider.notifier)
        .setPushNotifications(enabled);
    if (!context.mounted) return;

    if (ok) {
      AppSnackBar.show(
        context,
        message: enabled
            ? (isFirebaseConfiguredForPush()
                ? DiscProfile.prefPushEnabled
                : DiscProfile.prefPushWebEnabled)
            : DiscProfile.prefPushDisabled,
      );
      return;
    }

    if (!isFirebaseConfiguredForPush()) return;

    AppSnackBar.show(
      context,
      message: DiscProfile.prefPushDenied,
      kind: AppSnackKind.warning,
    );
  }

  Future<void> _onGeoChanged(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final ok = await ref
        .read(profilePreferencesProvider.notifier)
        .setGeolocation(enabled);
    if (!context.mounted) return;

    if (ok) {
      AppSnackBar.show(
        context,
        message: enabled
            ? DiscProfile.prefLocationEnabled
            : DiscProfile.prefLocationDisabled,
      );
      return;
    }

    AppSnackBar.show(
      context,
      message: DiscProfile.prefLocationDenied,
      kind: AppSnackKind.warning,
    );
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscProfile.prefLocation),
        content: const Text(DiscProfile.prefLocationDenied),
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
    if (open == true && context.mounted) {
      await ref.read(appPermissionsServiceProvider).openSystemSettings();
    }
  }

  Future<void> _onBiometricChanged(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final ok = await ref
        .read(profilePreferencesProvider.notifier)
        .setBiometricUnlock(enabled);
    if (!context.mounted) return;

    if (ok) {
      AppSnackBar.show(
        context,
        message: enabled
            ? DiscProfile.prefBiometricEnabled
            : DiscProfile.prefBiometricDisabled,
      );
      return;
    }

    AppSnackBar.show(
      context,
      message: enabled
          ? DiscProfile.prefBiometricSetupFailed
          : DiscProfile.prefBiometricDisabled,
      kind: AppSnackKind.warning,
    );
  }

  String _biometricTitle(BiometricAvailability availability) {
    if (availability.label == DiscProfile.prefBiometricFaceIdLabel) {
      return DiscProfile.prefBiometric;
    }
    if (availability.label == DiscProfile.prefBiometricFingerprintLabel) {
      return DiscProfile.prefBiometricFingerprint;
    }
    return DiscProfile.prefBiometricTouchId;
  }

  IconData _biometricIcon(BiometricAvailability availability) {
    if (availability.label == DiscProfile.prefBiometricFaceIdLabel) {
      return Icons.face_rounded;
    }
    return Icons.fingerprint_rounded;
  }
}

class _PreferenceToggle extends StatelessWidget {
  const _PreferenceToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.3,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
