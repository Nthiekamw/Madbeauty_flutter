import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../router/navigation_extensions.dart';
import '../../auth/providers/auth_notifier.dart';
import '../providers/home_profile_provider.dart';
import '../../../shared/theme/app_text_styles.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<bool> _confirmSignOut(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(AppStrings.accountSignOutConfirmTitle),
            content: const Text(AppStrings.accountSignOutConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(AppStrings.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(AppStrings.actionConfirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final isAuthLoading = auth.isLoading;
    final isOnlineAsync = ref.watch(onlineStatusProvider);
    final cachedEmailAsync = ref.watch(cachedLastSignedInEmailProvider);
    final profileSnapshotAsync = ref.watch(homeProfileSnapshotProvider);
    final currentUser = switch (auth) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.appName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.appName, style: AppTextStyles.display(context)),
              const SizedBox(height: 12),
              Text(AppStrings.tagline, style: AppTextStyles.body(context)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    switch (isOnlineAsync) {
                      AsyncData(:final value) => value
                          ? AppStrings.networkStatusOnline
                          : AppStrings.networkStatusOffline,
                      _ => AppStrings.networkStatusOnline,
                    },
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              if (currentUser?.email != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: switch (profileSnapshotAsync) {
                      AsyncData(:final value) when value != null => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppStrings.profileLabelName} ${value.displayName.isEmpty ? '—' : value.displayName}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${AppStrings.profileLabelEmail} ${value.email.isEmpty ? currentUser!.email : value.email}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              value.isFromCache
                                  ? AppStrings.profileSourceCache
                                  : AppStrings.profileSourceLive,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      _ => Text(
                          '${AppStrings.accountConnectedAsPrefix} ${currentUser!.email}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    },
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      switch (cachedEmailAsync) {
                        AsyncData(:final value) when value != null =>
                          '${AppStrings.accountCachedEmailPrefix} $value',
                        _ => '${AppStrings.accountCachedEmailPrefix} —',
                      },
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (!AppConfig.hasSupabase)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.supabaseMissingTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.supabaseMissingBody,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: context.pushLogin,
                child: Text(AppStrings.signInOrSignUp),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: context.goPrestataire,
                child: Text(AppStrings.openPrestataireSpace),
              ),
              if (AppConfig.hasSupabase) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isAuthLoading
                      ? null
                      : () async {
                          final shouldSignOut = await _confirmSignOut(context);
                          if (!shouldSignOut) return;
                          await ref.read(authNotifierProvider.notifier).signOut();
                        },
                  child: isAuthLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppStrings.accountActionSignOut),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
