import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../router/navigation_extensions.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../prestataire/navigation/prestataire_navigation.dart';
import '../models/home_profile_snapshot.dart';
import '../providers/home_profile_provider.dart';
import '../widgets/client_home_explore_row.dart';
import '../widgets/client_home_header.dart';
import '../widgets/client_home_nearby_prestataires_section.dart';
import '../widgets/client_home_top_rated_prestataires_section.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _confirmSignOut() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(ShellStrings.accountSignOutConfirmTitle),
            content: const Text(ShellStrings.accountSignOutConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(CoreStrings.actionCancel),
              ),
              AppButton(
                variant: AppButtonVariant.primary,
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(CoreStrings.actionConfirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _openListing({String? query}) {
    FocusScope.of(context).unfocus();
    final q = query ?? _searchController.text.trim();
    context.goClientSearch(query: q.isEmpty ? null : q);
  }

  String? _avatarUrlFromUser(User? user) {
    if (user == null) return null;
    final v = user.userMetadata?['avatar_url'];
    return v is String && v.trim().isNotEmpty ? v.trim() : null;
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: currentUser != null
            ? _ConnectedClientHome(
                searchController: _searchController,
                onSubmitSearch: () => _openListing(),
                onExplorePick: (topic) => _openListing(query: topic),
                isOnlineAsync: isOnlineAsync,
                profileSnapshotAsync: profileSnapshotAsync,
                currentUser: currentUser,
                avatarUrl: _avatarUrlFromUser(currentUser),
                onSignOut: () async {
                  final ok = await _confirmSignOut();
                  if (!ok || !mounted) return;
                  await ref.read(authNotifierProvider.notifier).signOut();
                },
                onOpenPrestataireSpace: () =>
                    PrestataireNavigation.openSpace(context, ref),
              )
            : _GuestFallback(
                isOnlineAsync: isOnlineAsync,
                cachedEmailAsync: cachedEmailAsync,
                isAuthLoading: isAuthLoading,
                onSignOut: () async {
                  final ok = await _confirmSignOut();
                  if (!ok || !mounted) return;
                  await ref.read(authNotifierProvider.notifier).signOut();
                },
              ),
      ),
    );
  }
}

class _ConnectedClientHome extends StatelessWidget {
  const _ConnectedClientHome({
    required this.searchController,
    required this.onSubmitSearch,
    required this.onExplorePick,
    required this.isOnlineAsync,
    required this.profileSnapshotAsync,
    required this.currentUser,
    required this.avatarUrl,
    required this.onSignOut,
    required this.onOpenPrestataireSpace,
  });

  final TextEditingController searchController;
  final VoidCallback onSubmitSearch;
  final ValueChanged<String> onExplorePick;
  final AsyncValue<bool> isOnlineAsync;
  final AsyncValue<HomeProfileSnapshot?> profileSnapshotAsync;
  final User currentUser;
  final String? avatarUrl;
  final Future<void> Function() onSignOut;
  final Future<void> Function() onOpenPrestataireSpace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = switch (profileSnapshotAsync) {
      AsyncData(:final value) when value != null && value.email.isNotEmpty =>
        value.email,
      _ => currentUser.email ?? '',
    };
    final displayName = switch (profileSnapshotAsync) {
      AsyncData(:final value) when value != null => value.displayName,
      _ => (currentUser.userMetadata?['full_name'] as String?) ?? '',
    };

    final greeting = DiscHome.greeting(displayName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        ClientHomeHeader(
          greetingLine: greeting,
          subtitle: DiscHome.taglineDiscovery,
          displayName: displayName,
          email: email,
          avatarUrl: avatarUrl,
          menuButton: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            onSelected: (value) async {
              if (value == 'prestataire') {
                await onOpenPrestataireSpace();
              }
              if (value == 'async-state-test') {
                if (!context.mounted) return;
                context.pushAsyncStateTest();
              }
              if (value == 'signout') {
                await onSignOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'prestataire',
                child: Text(ShellStrings.openPrestataireSpace),
              ),
              if (kDebugMode)
                const PopupMenuItem(
                  value: 'async-state-test',
                  child: Text('Tester loading / data / error'),
                ),
              PopupMenuItem(
                value: 'signout',
                child: Text(ShellStrings.accountActionSignOut),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          CoreStrings.tagline,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: searchController,
          hint: DiscHome.hintSearch,
          textInputAction: TextInputAction.search,
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: IconButton(
            tooltip: DiscHome.actionSearch,
            onPressed: onSubmitSearch,
            icon: Icon(Icons.arrow_forward, color: theme.colorScheme.primary),
          ),
          onSubmitted: (_) => onSubmitSearch(),
        ),
        const SizedBox(height: 28),
        ClientHomeExploreRow(onPick: onExplorePick),
        if (AppConfig.hasSupabase) ...[
          const SizedBox(height: 28),
          const ClientHomeNearbyPrestatairesSection(),
          const SizedBox(height: 28),
          const ClientHomeTopRatedPrestatairesSection(),
        ],
        if (!AppConfig.hasSupabase) ...[
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ShellStrings.supabaseMissingTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ShellStrings.supabaseMissingBody,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(
              switch (isOnlineAsync) {
                AsyncData(:final value) => value ? Icons.wifi : Icons.wifi_off,
                _ => Icons.wifi,
              },
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                switch (isOnlineAsync) {
                  AsyncData(:final value) =>
                    value
                        ? ShellStrings.networkStatusOnline
                        : ShellStrings.networkStatusOffline,
                  _ => ShellStrings.networkStatusOnline,
                },
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        if (switch (profileSnapshotAsync) {
          AsyncData(:final value) when value != null => value.isFromCache,
          _ => false,
        }) ...[
          const SizedBox(height: 8),
          Text(
            ShellStrings.profileSourceCache,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }
}

/// Cas dégradé (session absente alors que la route est encore affichée).
class _GuestFallback extends StatelessWidget {
  const _GuestFallback({
    required this.isOnlineAsync,
    required this.cachedEmailAsync,
    required this.isAuthLoading,
    required this.onSignOut,
  });

  final AsyncValue<bool> isOnlineAsync;
  final AsyncValue<String?> cachedEmailAsync;
  final bool isAuthLoading;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(CoreStrings.appName, style: AppTextStyles.display(context)),
          const SizedBox(height: 12),
          Text(CoreStrings.tagline, style: AppTextStyles.body(context)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(switch (isOnlineAsync) {
                AsyncData(:final value) =>
                  value
                      ? ShellStrings.networkStatusOnline
                      : ShellStrings.networkStatusOffline,
                _ => ShellStrings.networkStatusOnline,
              }, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(switch (cachedEmailAsync) {
                AsyncData(:final value) when value != null =>
                  '${ShellStrings.accountCachedEmailPrefix} $value',
                _ => '${ShellStrings.accountCachedEmailPrefix} —',
              }, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          const Spacer(),
          AppButton(
            variant: AppButtonVariant.primary,
            onPressed: context.pushLogin,
            child: Text(ShellStrings.signInOrSignUp),
          ),
          const SizedBox(height: 12),
          AppButton(
            variant: AppButtonVariant.secondary,
            onPressed: context.pushRegister,
            child: Text(ShellStrings.openPrestataireSpace),
          ),
          if (AppConfig.hasSupabase) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: isAuthLoading ? null : () => onSignOut(),
              child: Text(ShellStrings.accountActionSignOut),
            ),
          ],
        ],
      ),
    );
  }
}
