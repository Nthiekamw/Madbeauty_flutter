import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../router/app_router.dart';
import '../../navigation/post_auth_navigation.dart';
import '../../../../router/navigation_extensions.dart';
import '../../guest/guest_mode_provider.dart';
import '../../providers/auth_notifier.dart';
import '../models/login_view_state.dart';
import '../providers/login_controller.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
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
    await ref.read(loginControllerProvider.notifier).submit(
          rawEmail: _emailController.text,
          rawPassword: _passwordController.text,
        );
  }

  Future<void> _google() async {
    FocusScope.of(context).unfocus();
    final opened =
        await ref.read(loginControllerProvider.notifier).startGoogleSignIn();
    if (!mounted) return;
    if (opened) {
      AppSnackBar.info(context, AuthStrings.loginGoogleStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginViewState>(loginControllerProvider, (previous, next) {
      if (next.requestSupabaseSnack) {
        AppSnackBar.warning(context, ShellStrings.supabaseMissingTitle);
        ref.read(loginControllerProvider.notifier).acknowledgeSupabaseSnack();
      }
      if (next.shouldPopRoute) {
        if (context.mounted) {
          PostAuthNavigation.navigate(context, ref);
        }
        ref.read(loginControllerProvider.notifier).acknowledgeRouteClose();
      }
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
      submitError: loginUi.submitError,
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
