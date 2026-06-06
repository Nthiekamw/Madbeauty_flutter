import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/profile/providers/app_version_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).maybeWhen(
          data: (u) => u,
          orElse: () => null,
        );
    final email = user?.email?.trim() ?? '';
    final versionAsync = ref.watch(appVersionProvider);

    return AdminScreenScaffold(
      title: ShellStrings.navAdminProfile,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: DiscoveryStyles.cardBorderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.adminAccent.withValues(alpha: 0.16),
                  theme.colorScheme.surface,
                ],
              ),
              border: Border.all(color: AppColors.adminBorder30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.adminBg12,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.adminBorder30, width: 2),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      size: 32,
                      color: AppColors.adminAccentMid,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    DiscProfile.adminBadgeLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    DiscProfile.adminProfileRoleHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _signOut(context, ref),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: Text(ShellStrings.accountActionSignOut),
          ),
          const SizedBox(height: 16),
          versionAsync.when(
            data: (version) => Text(
              '${ShellStrings.profileVersionLabel} $version',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            loading: () => const SizedBox(height: 8),
            error: (_, __) => const SizedBox(height: 8),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ShellStrings.accountSignOutConfirmTitle),
        content: const Text(ShellStrings.accountSignOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(ShellStrings.accountActionSignOut),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    try {
      await ref.read(authNotifierProvider.notifier).signOut();
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminSignOutErr,
          kind: AppSnackKind.error,
        );
      }
    }
  }
}
