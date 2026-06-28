import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/app/app_button.dart';
import '../../../shared/widgets/layout/web_client_page_header.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import '../models/home_profile_snapshot.dart';
import '../providers/home_profile_provider.dart';
import '../widgets/header/client_home_hero_header.dart';
import '../widgets/layout/client_home_scroll_content.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    final theme = Theme.of(context);

    Widget body;
    if (currentUser != null) {
      body = _ConnectedClientHome(
        profileSnapshotAsync: profileSnapshotAsync,
      );
    } else if (isGuestBrowsing) {
      body = const _GuestBrowseHome();
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

    final isDark = theme.brightness == Brightness.dark;
    final useWebLayout = DiscoveryResponsive.of(context).useWebSiteLayout;

    if (useWebLayout) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WebClientPageHeader(
              title: ShellStrings.navClientHome,
              subtitle: DiscClientWorkspace.homeWebSubtitle,
            ),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? theme.colorScheme.surface : AppColors.lightSurface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ClientHomeHeroHeader(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

class _ConnectedClientHome extends StatelessWidget {
  const _ConnectedClientHome({
    required this.profileSnapshotAsync,
  });

  final AsyncValue<HomeProfileSnapshot?> profileSnapshotAsync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fromCache = switch (profileSnapshotAsync) {
      AsyncData(:final value) when value != null => value.isFromCache,
      _ => false,
    };

    return ClientHomeScrollContent(
      footer: clientHomeProfileCacheFooter(theme, fromCache),
    );
  }
}

/// Accueil client sans compte : découverte catalogue uniquement.
class _GuestBrowseHome extends StatelessWidget {
  const _GuestBrowseHome();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClientHomeScrollContent(
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
