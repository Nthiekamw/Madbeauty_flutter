import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../features/auth/navigation/post_auth_navigation.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/auth/register/storage/register_wizard_draft_store.dart';
import '../../../router/app_router.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../widgets/splash_brand_background.dart';

/// Splash minimum 2 s puis onboarding / bienvenue ou application si déjà connecté.
class StartupSplashScreen extends ConsumerStatefulWidget {
  const StartupSplashScreen({super.key});

  @override
  ConsumerState<StartupSplashScreen> createState() =>
      _StartupSplashScreenState();
}

class _StartupSplashScreenState extends ConsumerState<StartupSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final container = ProviderScope.containerOf(context);
      _boot(container);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
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
    final registerDraft = RegisterWizardDraftStore.instance.hasDraft;

    if (registerDraft) {
      if (!mounted) return;
      context.go(AppRoutes.register);
      return;
    }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SplashBrandBackground(isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: slide,
                    child: const _SplashBrandMark(),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: fade,
                  child: Text(
                    CoreStrings.tagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: AppFonts.body,
                      color: onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                FadeTransition(
                  opacity: fade,
                  child: _SplashLoadingFooter(
                    statusText: ShellStrings.splashCheckingSession,
                    indicatorColor: primary,
                    textColor: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBrandMark extends StatelessWidget {
  const _SplashBrandMark();

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          AppAssets.logo,
          width: 300,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => Icon(
            Icons.image_not_supported_outlined,
            size: 64,
            color: onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          ShellStrings.splashWelcomeBack,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w500,
                color: onSurfaceVariant,
                letterSpacing: 0.2,
              ),
        ),
      ],
    );
  }
}

class _SplashLoadingFooter extends StatelessWidget {
  const _SplashLoadingFooter({
    required this.statusText,
    required this.indicatorColor,
    required this.textColor,
  });

  final String statusText;
  final Color indicatorColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: indicatorColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            statusText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: AppFonts.body,
                  color: textColor,
                  letterSpacing: 0.15,
                ),
          ),
        ],
      ),
    );
  }
}
