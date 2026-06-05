import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/permissions/permissions_providers.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../providers/profile_preferences_provider.dart';
import 'profile_section_title.dart';

class ProfilePreferencesSection extends ConsumerWidget {
  const ProfilePreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(profilePreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProfileSectionTitle(title: DiscProfile.sectionPreferences),
        DiscoverySurfaceCard(
          child: Column(
            children: [
              _PreferenceToggle(
                icon: Icons.notifications_active_outlined,
                title: DiscProfile.prefPush,
                subtitle: DiscProfile.prefPushHint,
                value: prefs.pushNotificationsEnabled,
                onChanged: (value) => _onPushChanged(context, ref, value),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.1,
                ),
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
            ? DiscProfile.prefPushEnabled
            : DiscProfile.prefPushDisabled,
      );
      return;
    }

    AppSnackBar.show(
      context,
      message: DiscProfile.prefPushDenied,
      kind: AppSnackKind.warning,
    );
    final open = await showDialog<bool>(
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
            child: const Text('Réglages'),
          ),
        ],
      ),
    );
    if (open == true && context.mounted) {
      await ref.read(appPermissionsServiceProvider).openSystemSettings();
    }
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
            child: const Text('Réglages'),
          ),
        ],
      ),
    );
    if (open == true && context.mounted) {
      await ref.read(appPermissionsServiceProvider).openSystemSettings();
    }
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

