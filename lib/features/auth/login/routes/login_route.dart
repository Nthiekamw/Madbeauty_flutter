import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../router/app_router.dart';
import '../../navigation/post_auth_navigation.dart';
import '../../../../router/navigation_extensions.dart';
import '../../guest/guest_mode_provider.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/auth_success_dialog.dart';
import '../models/login_view_state.dart';
import '../providers/login_controller.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../screens/login_page.dart';

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
  bool _welcomeHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      exitGuestMode(ref);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
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

  Future<void> _completeLoginWithWelcome() async {
    if (_welcomeHandled || !mounted) return;
    _welcomeHandled = true;
    _googleSignInPending = false;

    await AuthSuccessDialog.show(
      context,
      title: AuthStrings.loginSuccessTitle,
      body: AuthStrings.loginSuccessBody,
      actionLabel: AuthStrings.loginSuccessCta,
    );
    if (!mounted) return;
    await PostAuthNavigation.navigate(context, ref);
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
      if (!_googleSignInPending || _welcomeHandled) return;
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
      onSubmitPassword: _submitPassword,
      onOpenRegister: context.pushRegister,
      onPasswordFieldSubmitted: _submitPassword,
      onEmailChanged: ref.read(loginControllerProvider.notifier).onEmailChanged,
      onPasswordChanged:
          ref.read(loginControllerProvider.notifier).onPasswordChanged,
      onGoogle: _google,
      onForgotPassword: context.pushForgotPassword,
    );
  }
}
