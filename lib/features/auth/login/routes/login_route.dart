import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../providers/auth_notifier.dart';
import '../models/login_view_state.dart';
import '../providers/login_controller.dart';
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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
    FocusScope.of(context).unfocus();
    await ref.read(loginControllerProvider.notifier).submit(
          rawEmail: _emailController.text,
          rawPassword: _passwordController.text,
        );
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    await ref.read(loginControllerProvider.notifier).sendOtp(
          rawEmail: _emailController.text,
          rawPhone: _phoneController.text,
        );
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    await ref.read(loginControllerProvider.notifier).verifyOtp(
          rawEmail: _emailController.text,
          rawPhone: _phoneController.text,
          rawOtp: _otpController.text,
        );
  }

  Future<void> _google() async {
    FocusScope.of(context).unfocus();
    final opened =
        await ref.read(loginControllerProvider.notifier).startGoogleSignIn();
    if (!mounted) return;
    if (opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthStrings.loginGoogleStarted)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginViewState>(loginControllerProvider, (previous, next) {
      if (next.requestSupabaseSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ShellStrings.supabaseMissingTitle)),
        );
        ref.read(loginControllerProvider.notifier).acknowledgeSupabaseSnack();
      }
      if (next.shouldPopRoute) {
        if (context.mounted) {
          context.goRoleChoice();
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
      authMethod: loginUi.authMethod,
      onAuthMethodChanged:
          ref.read(loginControllerProvider.notifier).setAuthMethod,
      emailController: _emailController,
      passwordController: _passwordController,
      phoneController: _phoneController,
      otpController: _otpController,
      emailError: loginUi.emailError,
      passwordError: loginUi.passwordError,
      phoneError: loginUi.phoneError,
      otpError: loginUi.otpError,
      submitError: loginUi.submitError,
      otpCodeSent: loginUi.otpCodeSent,
      isLoading: isLoading,
      formEnabled: formEnabled,
      onBack: () => context.canPop() ? context.pop() : context.goHome(),
      onSubmitPassword: _submitPassword,
      onSendOtp: _sendOtp,
      onVerifyOtp: _verifyOtp,
      onOpenRegister: context.pushRegister,
      onPasswordFieldSubmitted: _submitPassword,
      onEmailChanged: ref.read(loginControllerProvider.notifier).onEmailChanged,
      onPasswordChanged:
          ref.read(loginControllerProvider.notifier).onPasswordChanged,
      onPhoneChanged: ref.read(loginControllerProvider.notifier).onPhoneChanged,
      onOtpChanged: ref.read(loginControllerProvider.notifier).onOtpChanged,
      onGoogle: _google,
      onForgotPassword: context.pushForgotPassword,
    );
  }
}
