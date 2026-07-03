import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../router/app_router.dart';
import '../../../../router/navigation_extensions.dart';
import '../../guest/guest_mode_provider.dart';
import '../../logic/account_ban_handler.dart';
import '../../navigation/auth_session_cache.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/auth_redirect_providers.dart';
import '../../widgets/auth_success_dialog.dart';
import '../../../../services/auth/apple_auth_service.dart';
import '../providers/login_controller.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../screens/login_page.dart';
import '../models/login_view_state.dart';

/// Entrée route `/login` : Riverpod, navigation et [SnackBar] (hors design).
class LoginRoute extends ConsumerStatefulWidget {
  const LoginRoute({super.key});

  @override
  ConsumerState<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends ConsumerState<LoginRoute> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _googleSignInPending = false;
  bool _appleSignInPending = false;
  bool _welcomeHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      exitGuestMode(ref);
      ref.read(loginRedirectAfterWelcomeProvider.notifier).disarm();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    try {
      await ref.read(loginControllerProvider.notifier).submit(
            rawEmail: _emailController.text,
            rawPassword: _passwordController.text,
          );
    } on AppFailure catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, CoreStrings.errorUnexpected);
    }
  }

  Future<void> _google() async {
    FocusScope.of(context).unfocus();
    final opened =
        await ref.read(loginControllerProvider.notifier).startGoogleSignIn();
    if (!mounted) return;
    if (opened) {
      _googleSignInPending = true;
      AppSnackBar.info(context, AuthStrings.loginGoogleStarted);
    }
  }

  Future<void> _apple() async {
    FocusScope.of(context).unfocus();
    final opened =
        await ref.read(loginControllerProvider.notifier).startAppleSignIn();
    if (!mounted) return;
    if (opened) {
      _appleSignInPending = true;
      unawaited(_completeLoginWithWelcome());
    }
  }

  Future<void> _completeLoginWithWelcome() async {
    if (_welcomeHandled || !mounted) return;
    _welcomeHandled = true;
    _googleSignInPending = false;
    _appleSignInPending = false;

    final container = ProviderScope.containerOf(context);
    final router = container.read(goRouterProvider);
    final loginRedirectNotifier =
        container.read(loginRedirectAfterWelcomeProvider.notifier);
    final bumpRedirect = container.read(routerRedirectBumpProvider);

    final rootContext = router.routerDelegate.navigatorKey.currentContext;
    final dialogContext = rootContext ?? (mounted ? context : null);

    if (!await AccountBanHandler.ensureNotBanned(
      container,
      dialogContext: dialogContext,
      router: router,
    )) {
      return;
    }

    if (dialogContext == null) return;

    await AuthSuccessDialog.show(
      dialogContext,
      title: AuthStrings.loginSuccessTitle,
      body: AuthStrings.loginSuccessBody,
      actionLabel: AuthStrings.loginSuccessCta,
    );

    if (container.read(authNotifierProvider).value == null) return;

    final prepared =
        await AuthSessionCache.prepareForAuthenticatedRedirect(container);
    if (!prepared || container.read(authNotifierProvider).value == null) {
      return;
    }

    loginRedirectNotifier.arm();
    bumpRedirect();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginViewState>(loginControllerProvider, (previous, next) {
      if (next.requestSupabaseSnack) {
        AppSnackBar.warning(context, ShellStrings.supabaseMissingTitle);
        ref.read(loginControllerProvider.notifier).acknowledgeSupabaseSnack();
      }
      if (next.submitError != null && previous?.submitError != next.submitError) {
        AppSnackBar.error(context, next.submitError!);
        ref.read(loginControllerProvider.notifier).acknowledgeSubmitError();
      }
      if (next.shouldPopRoute) {
        ref.read(loginControllerProvider.notifier).acknowledgeRouteClose();
        unawaited(_completeLoginWithWelcome());
      }
    });

    ref.listen(authNotifierProvider, (previous, next) {
      if ((!_googleSignInPending && !_appleSignInPending) || _welcomeHandled) {
        return;
      }
      final user = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user == null) return;
      final hadUser = switch (previous) {
        AsyncData(:final value) => value != null,
        _ => false,
      };
      if (hadUser) return;
      unawaited(_completeLoginWithWelcome());
    });

    final loginUi = ref.watch(loginControllerProvider);
    final authAsync = ref.watch(authNotifierProvider);
    final authLoading = authAsync.isLoading;
    final isLoading = authLoading || loginUi.isBusy;
    final formEnabled = AppConfig.hasSupabase && !authLoading && !loginUi.isBusy;

    return LoginPage(
      showSupabaseConfigCard: !AppConfig.hasSupabase,
      emailController: _emailController,
      passwordController: _passwordController,
      emailError: loginUi.emailError,
      passwordError: loginUi.passwordError,
      submitError: null,
      isLoading: isLoading,
      formEnabled: formEnabled,
      onBack: () =>
          context.canPop() ? context.pop() : context.goNamed(AppRouteNames.welcome),
      onSubmit: _submit,
      onOpenRegister: context.pushRegister,
      onPasswordFieldSubmitted: _submit,
      onEmailChanged: ref.read(loginControllerProvider.notifier).onEmailChanged,
      onPasswordChanged:
          ref.read(loginControllerProvider.notifier).onPasswordChanged,
      onGoogle: _google,
      onApple: AppleAuthService.isNativeAppleSignInAvailable() ? _apple : null,
      onForgotPassword: context.pushForgotPassword,
    );
  }
}
