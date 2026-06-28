import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../firebase_runtime_helpers.dart';
import '../../../../services/permissions/permissions_providers.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../logic/profile_push_permission_prompt.dart';
import '../../providers/profile_preferences_provider.dart';
import '../../providers/profile_tab_visibility_provider.dart';
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
  Widget build(BuildContext context) {
    ref.listen<int>(profileTabVisibleTickProvider, (previous, next) {
      if (previous == null || next <= previous) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          unawaited(promptPushPermissionIfNeeded(context, ref));
        }
      });
    });

    final prefs = ref.watch(profilePreferencesProvider);
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
                subtitleColor: prefs.pushNotificationsEnabled
                    ? null
                    : (nativePush
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant),
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
            child: const Text(DiscProfile.prefOpenSettings),
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
            child: const Text(DiscProfile.prefOpenSettings),
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
    this.subtitleColor,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? subtitleColor;
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
          color: subtitleColor ?? theme.colorScheme.onSurfaceVariant,
          height: 1.3,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
