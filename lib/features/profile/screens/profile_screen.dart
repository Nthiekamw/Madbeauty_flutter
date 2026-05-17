import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/widgets/role_switch_section.dart';
import '../../../router/navigation_extensions.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ShellStrings.accountSignOutConfirmTitle),
        content: const Text(ShellStrings.accountSignOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    await ref.read(authNotifierProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authSnapshot = ref.watch(authNotifierProvider);
    final user = switch (authSnapshot) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text(DiscNav.profileTitle)),
      body: ListView(
        children: [
          if (user?.email != null && user!.email!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                '${ShellStrings.accountConnectedAsPrefix} ${user.email}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const RoleSwitchSection(sectionTitle: DiscNav.profileSpace),
          ListTile(
            leading: Icon(
              Icons.event_available_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(DiscNav.myReservationsTitle),
            subtitle: Text(
              DiscNav.profileResHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
            ),
            onTap: () => context.goMyReservations(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              ShellStrings.accountActionSignOut,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}
