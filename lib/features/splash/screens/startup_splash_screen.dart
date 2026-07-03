import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../features/auth/logic/account_ban_handler.dart';
import '../../../features/auth/logic/auth_role_cache.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/auth/providers/auth_redirect_providers.dart';
import '../../../router/navigation_extensions.dart';
import '../../../features/auth/providers/my_roles_provider.dart';
import '../../../features/auth/register/logic/register_wizard_submit_handler.dart';
import '../../../features/auth/register/storage/register_wizard_draft_store.dart';
import '../../../features/prestataire/navigation/prestataire_navigation.dart';
import '../../../router/app_router.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/brand/brand_logo.dart';
import '../splash_config.dart';
import '../widgets/splash_brand_background.dart';
import '../widgets/splash_style.dart';

/// Splash : animation de marque, bootstrap auth / rôles, puis navigation.
class StartupSplashScreen extends ConsumerStatefulWidget {
  const StartupSplashScreen({super.key});

  @override
  ConsumerState<StartupSplashScreen> createState() =>
      _StartupSplashScreenState();
}

class _StartupSplashScreenState extends ConsumerState<StartupSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  late final DateTime _displayStartedAt;
  String _statusText = ShellStrings.splashInitializing;

  @override
  void initState() {
    super.initState();
    _displayStartedAt = DateTime.now();
    _intro = AnimationController(
      vsync: this,
      duration: SplashConfig.introAnimationDuration,
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final container = ProviderScope.containerOf(context);
      unawaited(_boot(container));
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _setStatus(String text) {
    if (!mounted || _statusText == text) return;
    setState(() => _statusText = text);
  }

  Future<void> _waitMinDisplay() async {
    final elapsed = DateTime.now().difference(_displayStartedAt);
    final remaining = SplashConfig.minDisplayDuration - elapsed;
    if (remaining > Duration.zero) {
      _setStatus(ShellStrings.splashAlmostReady);
      await Future<void>.delayed(remaining);
    }
  }

  Future<void> _navigate(FutureOr<void> Function() action) async {
    await _waitMinDisplay();
    if (!mounted) return;
    await action();
  }

  Future<void> _go(String route) => _navigate(() async {
        final router = ref.read(goRouterProvider);
        await router.goDeferred(route);
      });

  void _handoffSplashToRedirect(String target) {
    ref.read(splashRedirectTargetProvider.notifier).setTarget(target);
    ref.read(routerRedirectBumpProvider)();
  }

  Future<void> _boot(ProviderContainer container) async {
    _setStatus(ShellStrings.splashCheckingSession);

    final authSnapshot = container.read(authNotifierProvider);
    if (authSnapshot.isLoading) {
      try {
        await container.read(authNotifierProvider.future);
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('Splash: auth init – $e\n$st');
        }
      }
    }

    if (!mounted) return;

    final authAfterWait = container.read(authNotifierProvider);
    final user = switch (authAfterWait) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final cache = LocalCacheService.instance;
    final registerDraftStore = RegisterWizardDraftStore.instance;
    final registerDraft = registerDraftStore.read();
    final hasSession = AppConfig.hasSupabase &&
        container.read(authServiceProvider).currentSession != null;

    if (registerDraft != null && registerDraft.isActive) {
      if (registerDraft.pendingEmailVerification && !hasSession) {
        final email = Uri.encodeComponent(registerDraft.email.trim());
        await _go('${AppRoutes.registerVerifyEmail}?email=$email');
        return;
      }
      if (hasSession) {
        final finalized = await _tryFinalizeRegistrationDraft(container);
        if (finalized) return;
      }
      if (!hasSession) {
        await _go(AppRoutes.register);
        return;
      }
      if (registerDraft.step == 2) {
        await _go('${AppRoutes.register}?resume=1');
      } else {
        await _go(AppRoutes.register);
      }
      return;
    }

    if (user != null) {
      if (!await AccountBanHandler.ensureNotBanned(
        container,
        dialogContext: mounted ? context : null,
      )) {
        return;
      }
      final handoffTarget = await _bootstrapAuthenticated(container);
      if (!mounted) return;
      if (handoffTarget != null) {
        await _navigate(() async => _handoffSplashToRedirect(handoffTarget));
      }
      return;
    }

    if (!mounted) return;

    if (!cache.onboardingCompleted) {
      await _go(AppRoutes.onboarding);
    } else {
      await _go(AppRoutes.welcome);
    }
  }

  Future<bool> _tryFinalizeRegistrationDraft(
    ProviderContainer container,
  ) async {
    final draft = RegisterWizardDraftStore.instance.read();
    if (draft == null || !draft.isActive) return false;
    if (!AppConfig.hasSupabase) return false;

    final session = container.read(authServiceProvider).currentSession;
    final user = session?.user;
    if (user == null || !mounted) return false;

    try {
      return await RegisterWizardSubmitHandler()
          .finalizePendingRegistrationFromDraft(
        context: context,
        mounted: () => mounted,
        ref: ref,
        session: user,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Splash: finalize inscription – $e\n$st');
      }
      return false;
    }
  }

  /// Chemin de handoff redirect, ou `null` si le splash doit rester (bootstrap en cours).
  Future<String?> _bootstrapAuthenticated(ProviderContainer container) async {
    final online = await container.read(connectivityServiceProvider).isOnline();
    if (!online) {
      if (kDebugMode) {
        debugPrint('Splash: hors ligne – bootstrap réseau ignoré');
      }
      return AuthRoleCache.preferredAuthenticatedPath();
    }

    _setStatus(ShellStrings.splashLoadingRoles);

    try {
      final roles = await container
          .read(myRolesProvider.future)
          .timeout(SplashConfig.bootstrapTimeout);
      await AuthRoleCache.persistServerRoles(roles);
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('Splash: bootstrap timeout – cache local');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Splash: bootstrap – $e\n$st');
      }
    }

    if (!AuthRoleCache.shouldBootstrapPrestataireProfile()) {
      return AuthRoleCache.preferredAuthenticatedPath();
    }

    _setStatus(ShellStrings.splashLoadingProfile);
    return PrestataireNavigation.prestataireSpacePath(container);
  }

  @override
  Widget build(BuildContext context) {
    final style = SplashStyle.of(context);
    final theme = Theme.of(context);
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SplashBrandBackground(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: slide,
                    child: _SplashBrandMark(style: style),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: fade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      CoreStrings.tagline,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: AppFonts.body,
                        color: style.taglineColor,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 4),
                FadeTransition(
                  opacity: fade,
                  child: _SplashLoadingFooter(
                    statusText: _statusText,
                    indicatorColor: style.indicatorColor,
                    textColor: style.statusColor,
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
  const _SplashBrandMark({required this.style});

  final SplashStyle style;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoWidth = (screenWidth * SplashConfig.logoWidthFraction)
        .clamp(SplashConfig.logoMinWidth, SplashConfig.logoMaxWidth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BrandLogo(
        width: logoWidth,
        showGlow: true,
        glowColor: style.glowColor,
        glowBlurRadius: style.isDark ? 56 : 44,
        glowSpreadRadius: style.isDark ? 14 : 10,
      ),
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
    return Semantics(
      label: statusText,
      liveRegion: true,
      child: Padding(
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Text(
                statusText,
                key: ValueKey<String>(statusText),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: AppFonts.body,
                      color: textColor,
                      letterSpacing: 0.15,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
