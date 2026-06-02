import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/notifications/in_app_notifications_sheet.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import '../models/home_profile_snapshot.dart';
import '../providers/home_feed_provider.dart';
import '../providers/home_profile_provider.dart';
import '../../client/widgets/workspace/client_workspace_shell.dart';
import '../widgets/client_home_scroll_content.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/app/app_button.dart';
import '../../../shared/widgets/layout/brand_background.dart';

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

  void _submitHomeSearch() {
    FocusScope.of(context).unfocus();
    ref.read(homeFeedSelectionProvider.notifier).setSearch(
      _searchController.text,
    );
  }

  void _pickInspiration(String topic) {
    FocusScope.of(context).unfocus();
    ref.read(homeFeedSelectionProvider.notifier).setInspiration(topic);
  }

  void _openNotifications() {
    unawaited(showInAppNotificationsSheet(context, ref));
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
    final notificationUnread =
        ref.watch(unreadInAppNotificationsCountProvider);

    Widget body;
    if (currentUser != null) {
      body = _ConnectedClientHome(
        searchController: _searchController,
        onSubmitSearch: _submitHomeSearch,
        onExplorePick: _pickInspiration,
        onNotificationsTap: _openNotifications,
        notificationsUnreadCount: notificationUnread,
        profileSnapshotAsync: profileSnapshotAsync,
        currentUser: currentUser,
        avatarUrl: _avatarUrlFromUser(currentUser),
      );
    } else if (isGuestBrowsing) {
      body = _GuestBrowseHome(
        searchController: _searchController,
        onSubmitSearch: _submitHomeSearch,
        onExplorePick: _pickInspiration,
        onNotificationsTap: _openNotifications,
        notificationsUnreadCount: notificationUnread,
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
          SafeArea(
            child: ClientWorkspaceShell(
              subtitle: currentUser != null
                  ? DiscHome.taglineDiscovery
                  : AuthStrings.guestHomeSubtitle,
              child: body,
            ),
          ),
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
    required this.onNotificationsTap,
    required this.notificationsUnreadCount,
    required this.profileSnapshotAsync,
    required this.currentUser,
    required this.avatarUrl,
  });

  final TextEditingController searchController;
  final VoidCallback onSubmitSearch;
  final ValueChanged<String> onExplorePick;
  final VoidCallback onNotificationsTap;
  final int notificationsUnreadCount;
  final AsyncValue<HomeProfileSnapshot?> profileSnapshotAsync;
  final User currentUser;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fromCache = switch (profileSnapshotAsync) {
      AsyncData(:final value) when value != null => value.isFromCache,
      _ => false,
    };

    return ClientHomeScrollContent(
      searchController: searchController,
      onSubmitSearch: onSubmitSearch,
      onExplorePick: onExplorePick,
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
    required this.onNotificationsTap,
    required this.notificationsUnreadCount,
  });

  final TextEditingController searchController;
  final VoidCallback onSubmitSearch;
  final ValueChanged<String> onExplorePick;
  final VoidCallback onNotificationsTap;
  final int notificationsUnreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClientHomeScrollContent(
      searchController: searchController,
      onSubmitSearch: onSubmitSearch,
      onExplorePick: onExplorePick,
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
