import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../router/navigation_extensions.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import '../models/home_profile_snapshot.dart';
import '../providers/home_profile_provider.dart';
import '../widgets/client_home_header.dart';
import '../widgets/client_home_scroll_content.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand_background.dart';

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
    final cachedEmailAsync = ref.watch(cachedLastSignedInEmailProvider);
    final profileSnapshotAsync = ref.watch(homeProfileSnapshotProvider);
    final currentUser = switch (auth) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final isGuestBrowsing = ref.watch(isGuestBrowsingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget body;
    if (currentUser != null) {
      body = _ConnectedClientHome(
        searchController: _searchController,
        onSubmitSearch: () => _openListing(),
        onExplorePick: (topic) => _openListing(query: topic),
        profileSnapshotAsync: profileSnapshotAsync,
        currentUser: currentUser,
        avatarUrl: _avatarUrlFromUser(currentUser),
      );
    } else if (isGuestBrowsing) {
      body = _GuestBrowseHome(
        searchController: _searchController,
        onSubmitSearch: () => _openListing(),
        onExplorePick: (topic) => _openListing(query: topic),
      );
    } else {
      body = _GuestFallback(
        cachedEmailAsync: cachedEmailAsync,
        isAuthLoading: isAuthLoading,
        onSignOut: () async {
          final ok = await _confirmSignOut();
          if (!ok || !mounted) return;
          await ref.read(authNotifierProvider.notifier).signOut();
        },
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          BrandBackground(isDark: isDark),
          SafeArea(child: body),
        ],
      ),
    );
  }
}

class _ConnectedClientHome extends StatelessWidget {
  const _ConnectedClientHome({
    required this.searchController,
    required this.onSubmitSearch,
    required this.onExplorePick,
    required this.profileSnapshotAsync,
    required this.currentUser,
    required this.avatarUrl,
  });

  final TextEditingController searchController;
  final VoidCallback onSubmitSearch;
  final ValueChanged<String> onExplorePick;
  final AsyncValue<HomeProfileSnapshot?> profileSnapshotAsync;
  final User currentUser;
  final String? avatarUrl;

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

    final fromCache = switch (profileSnapshotAsync) {
      AsyncData(:final value) when value != null => value.isFromCache,
      _ => false,
    };

    return ClientHomeScrollContent(
      searchController: searchController,
      onSubmitSearch: onSubmitSearch,
      onExplorePick: onExplorePick,
      header: ClientHomeHeader(
        greetingLine: DiscHome.greeting(displayName),
        subtitle: DiscHome.taglineDiscovery,
        displayName: displayName,
        email: email,
        avatarUrl: avatarUrl,
        onAvatarTap: () => context.goClientProfile(),
      ),
      footer: clientHomeProfileCacheFooter(theme, fromCache),
    );
  }
}

/// Accueil client sans compte : découverte catalogue uniquement.
class _GuestBrowseHome extends StatelessWidget {
  const _GuestBrowseHome({
    required this.searchController,
    required this.onSubmitSearch,
    required this.onExplorePick,
  });

  final TextEditingController searchController;
  final VoidCallback onSubmitSearch;
  final ValueChanged<String> onExplorePick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClientHomeScrollContent(
      searchController: searchController,
      onSubmitSearch: onSubmitSearch,
      onExplorePick: onExplorePick,
      header: ClientHomeHeader(
        greetingLine: AuthStrings.guestHomeGreeting,
        subtitle: AuthStrings.guestHomeSubtitle,
        displayName: '',
        email: '',
        trailing: IconButton.filledTonal(
          tooltip: AuthStrings.guestHomeSignIn,
          onPressed: () => context.pushLogin(),
          icon: const Icon(Icons.login_rounded),
        ),
      ),
      footer: Text(
        AuthStrings.welcomeGuestHint,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }
}

/// Cas dégradé (session absente alors que la route est encore affichée).
class _GuestFallback extends StatelessWidget {
  const _GuestFallback({
    required this.cachedEmailAsync,
    required this.isAuthLoading,
    required this.onSignOut,
  });

  final AsyncValue<String?> cachedEmailAsync;
  final bool isAuthLoading;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(CoreStrings.appName, style: AppTextStyles.display(context)),
          const SizedBox(height: 12),
          Text(
            CoreStrings.tagline,
            style: AppTextStyles.body(context),
          ),
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                switch (cachedEmailAsync) {
                  AsyncData(:final value) when value != null =>
                    '${ShellStrings.accountCachedEmailPrefix} $value',
                  _ => '${ShellStrings.accountCachedEmailPrefix} —',
                },
                style: theme.textTheme.bodyMedium,
              ),
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
