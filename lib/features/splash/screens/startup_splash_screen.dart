import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../features/auth/logic/auth_role_cache.dart';
import '../../../features/auth/navigation/post_auth_navigation.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/auth/providers/my_roles_provider.dart';
import '../../../features/auth/register/storage/register_wizard_draft_store.dart';
import '../../../features/prestataire/logic/prestataire_profile_completeness.dart';
import '../../../features/prestataire/providers/profile/current_prestataire_provider.dart';
import '../../../features/prestataire/providers/profile/prestataire_profile_form_provider.dart';
import '../../../features/profile/logic/become_prestataire_flow_resume.dart';
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

  Future<void> _go(String route) => _navigate(() => context.go(route));

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
    final hasSession =
        container.read(authServiceProvider).currentSession != null;

    if (registerDraft != null && registerDraft.isActive) {
      if (registerDraft.pendingEmailVerification && !hasSession) {
        final email = Uri.encodeComponent(registerDraft.email.trim());
        await _go('${AppRoutes.registerVerifyEmail}?email=$email');
        return;
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

    final becomeResume = BecomePrestataireFlowResume.pathAfterAuthBootstrap();
    if (user != null && becomeResume != null) {
      if (BecomePrestataireFlowResume.needsPrestataireRole) {
        await LocalCacheService.instance.setSelectedRole('prestataire');
      }
      await _go(becomeResume);
      return;
    }

    if (user != null) {
      final navigatedAway = await _bootstrapAuthenticated(container);
      if (!mounted || navigatedAway) return;
      await _navigate(
        () => PostAuthNavigation.navigateWithContainer(context, container),
      );
      return;
    }

    if (!mounted) return;

    if (!cache.onboardingCompleted) {
      await _go(AppRoutes.onboarding);
    } else {
      await _go(AppRoutes.welcome);
    }
  }

  /// `true` si une navigation a déjà été déclenchée (ex. profil incomplet).
  Future<bool> _bootstrapAuthenticated(ProviderContainer container) async {
    final online = await container.read(connectivityServiceProvider).isOnline();
    if (!online) {
      if (kDebugMode) {
        debugPrint('Splash: hors ligne – bootstrap réseau ignoré');
      }
      return false;
    }

    _setStatus(ShellStrings.splashLoadingRoles);

    try {
      final roles = await container
          .read(myRolesProvider.future)
          .timeout(SplashConfig.bootstrapTimeout);
      await AuthRoleCache.persistServerRoles(roles);

      _setStatus(ShellStrings.splashLoadingProfile);

      final prestaProfile = await container
          .read(currentPrestataireProvider.future)
          .timeout(SplashConfig.bootstrapTimeout);
      if (prestaProfile != null) {
        await LocalCacheService.instance.setSelectedRole('prestataire');
        await LocalCacheService.instance.setSignupShellRole('prestataire');
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('Splash: bootstrap timeout – cache local');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Splash: bootstrap – $e\n$st');
      }
    }

    if (LocalCacheService.instance.selectedRole != 'prestataire') {
      return false;
    }

    _setStatus(ShellStrings.splashLoadingProfile);
    try {
      final profile = await container
          .read(prestataireProfileFormProvider.future)
          .timeout(SplashConfig.bootstrapTimeout);
      if (!profile.isProfessionallyComplete) {
        if (!mounted) return true;
        await _go(AppRoutes.prestataireProfileEdit);
        return true;
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('Splash: profil prestataire timeout');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Splash: profil prestataire – $e\n$st');
      }
    }
    return false;
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
