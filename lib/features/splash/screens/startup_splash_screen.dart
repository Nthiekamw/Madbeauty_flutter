import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/auth/navigation/post_auth_navigation.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../router/app_router.dart';
import '../../../services/storage/local_cache_service.dart';

/// Splash minimum 2 s puis onboarding / bienvenue ou application si déjà connecté.
class StartupSplashScreen extends ConsumerStatefulWidget {
  const StartupSplashScreen({super.key});

  @override
  ConsumerState<StartupSplashScreen> createState() =>
      _StartupSplashScreenState();
}

class _StartupSplashScreenState extends ConsumerState<StartupSplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Ne pas utiliser [ref] après délai async : au hot restart le callback peut
      // tourner une fois le widget démonté ([ref] dépend du contexte).
      final container = ProviderScope.containerOf(context);
      _boot(container);
    });
  }

  Future<void> _boot(ProviderContainer container) async {
    final minSplash = Future<void>.delayed(const Duration(seconds: 2));
    final authReady = container.read(authNotifierProvider.future);

    await Future.wait<void>([minSplash, authReady]);

    if (!mounted) return;

    final authSnapshot = container.read(authNotifierProvider);
    final user = switch (authSnapshot) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final cache = LocalCacheService.instance;

    if (user != null) {
      if (!mounted) return;
      await PostAuthNavigation.navigateWithContainer(context, container);
      return;
    }

    if (!mounted) return;
    if (!cache.onboardingCompleted) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ShellStrings.splashWelcomeBack,
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                ShellStrings.splashCheckingSession,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
