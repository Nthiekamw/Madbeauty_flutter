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
import '../../phone_otp/models/phone_otp_flow.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/auth_success_dialog.dart';
import '../../../../shared/utils/phone_number_utils.dart';
import '../models/login_credential_method.dart';
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
  final _phoneController = TextEditingController();
  String _phoneDialCode = '+33';
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
    _phoneController.dispose();
    super.dispose();
  }

  String get _phoneE164 => PhoneNumberUtils.toE164(
        dialCode: _phoneDialCode,
        local: _phoneController.text,
      );

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    try {
      await ref.read(loginControllerProvider.notifier).submit(
            rawEmail: _emailController.text,
            rawPassword: _passwordController.text,
            rawPhoneE164: _phoneE164,
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

  void _onCredentialMethodChanged(bool isPhone) {
    ref.read(loginControllerProvider.notifier).setCredentialMethod(
          isPhone ? LoginCredentialMethod.phone : LoginCredentialMethod.email,
        );
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
      if (next.infoMessage != null &&
          previous?.infoMessage != next.infoMessage) {
        AppSnackBar.info(context, next.infoMessage!);
        ref.read(loginControllerProvider.notifier).acknowledgeInfoMessage();
      }
      if (next.submitError != null && previous?.submitError != next.submitError) {
        AppSnackBar.error(context, next.submitError!);
        ref.read(loginControllerProvider.notifier).acknowledgeSubmitError();
      }
      if (next.shouldNavigateToPhoneOtp &&
          previous?.shouldNavigateToPhoneOtp != next.shouldNavigateToPhoneOtp) {
        ref.read(loginControllerProvider.notifier).acknowledgePhoneOtpNavigation();
        context.pushVerifyPhone(
          flow: PhoneOtpFlow.login.queryValue,
          phone: _phoneE164,
        );
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
      credentialMethod: loginUi.credentialMethod,
      emailController: _emailController,
      passwordController: _passwordController,
      phoneController: _phoneController,
      phoneDialCode: _phoneDialCode,
      onPhoneDialCodeChanged: (code) => setState(() => _phoneDialCode = code),
      emailError: loginUi.emailError,
      passwordError: loginUi.passwordError,
      phoneError: loginUi.phoneError,
      submitError: null,
      infoMessage: loginUi.infoMessage,
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
      onPhoneChanged: ref.read(loginControllerProvider.notifier).onPhoneChanged,
      onCredentialMethodChanged: _onCredentialMethodChanged,
      onGoogle: _google,
      onForgotPassword: context.pushForgotPassword,
    );
  }
}
