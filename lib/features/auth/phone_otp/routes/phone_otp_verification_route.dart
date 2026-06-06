import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../navigation/post_auth_navigation.dart';
import '../../widgets/auth_success_dialog.dart';
import '../models/phone_otp_flow.dart';
import '../providers/phone_otp_verification_controller.dart';
import '../screens/phone_otp_verification_screen.dart';

class PhoneOtpVerificationRoute extends ConsumerStatefulWidget {
  const PhoneOtpVerificationRoute({
    super.key,
    required this.flow,
    required this.phoneE164,
  });

  final PhoneOtpFlow flow;
  final String phoneE164;

  @override
  ConsumerState<PhoneOtpVerificationRoute> createState() =>
      _PhoneOtpVerificationRouteState();
}

class _PhoneOtpVerificationRouteState
    extends ConsumerState<PhoneOtpVerificationRoute> {
  final _otpController = TextEditingController();
  bool _loginWelcomeHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(phoneOtpVerificationControllerProvider.notifier).bootstrapFromRoute(
            flow: widget.flow,
            phoneE164: widget.phoneE164,
          );
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _completeLoginWelcome() async {
    if (_loginWelcomeHandled || !mounted) return;
    _loginWelcomeHandled = true;

    await AuthSuccessDialog.show(
      context,
      title: AuthStrings.loginSuccessTitle,
      body: AuthStrings.loginSuccessBody,
      actionLabel: AuthStrings.loginSuccessCta,
    );
    if (!mounted) return;
    ref.read(phoneOtpVerificationControllerProvider.notifier).reset();
    await PostAuthNavigation.navigate(context, ref);
  }

  Future<void> _onRegisterVerified() async {
    if (!mounted) return;
    ref.read(phoneOtpVerificationControllerProvider.notifier).reset();
    context.goRegisterPhoneVerified();
  }

  void _goBack() {
    ref.read(phoneOtpVerificationControllerProvider.notifier).reset();
    if (context.canPop()) {
      context.pop();
      return;
    }
    switch (widget.flow) {
      case PhoneOtpFlow.login:
        context.goLogin();
      case PhoneOtpFlow.register:
        context.goRegister();
    }
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    try {
      await ref
          .read(phoneOtpVerificationControllerProvider.notifier)
          .verify(_otpController.text);
    } on AppFailure catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, CoreStrings.errorUnexpected);
    }
  }

  Future<void> _resend() async {
    FocusScope.of(context).unfocus();
    try {
      await ref.read(phoneOtpVerificationControllerProvider.notifier).resend();
    } on AppFailure catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, CoreStrings.errorUnexpected);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(phoneOtpVerificationControllerProvider, (previous, next) {
      if (next.infoMessage != null &&
          previous?.infoMessage != next.infoMessage) {
        AppSnackBar.info(context, next.infoMessage!);
        ref
            .read(phoneOtpVerificationControllerProvider.notifier)
            .acknowledgeInfoMessage();
      }
      if (next.submitError != null &&
          previous?.submitError != next.submitError) {
        AppSnackBar.error(context, next.submitError!);
        ref
            .read(phoneOtpVerificationControllerProvider.notifier)
            .acknowledgeSubmitError();
      }
      if (next.loginSucceeded && !_loginWelcomeHandled) {
        unawaited(_completeLoginWelcome());
      }
      if (next.registerSucceeded) {
        unawaited(_onRegisterVerified());
      }
    });

    final ui = ref.watch(phoneOtpVerificationControllerProvider);
    final phone = ui.phoneE164?.trim().isNotEmpty == true
        ? ui.phoneE164!.trim()
        : widget.phoneE164.trim();
    final formEnabled = AppConfig.hasSupabase && !ui.isBusy;

    return PhoneOtpVerificationScreen(
      phoneE164: phone,
      otpController: _otpController,
      otpError: ui.otpError,
      submitError: null,
      infoMessage: ui.infoMessage,
      isBusy: ui.isBusy,
      isResending: ui.isResending,
      formEnabled: formEnabled,
      onBack: _goBack,
      onOtpChanged: ref
          .read(phoneOtpVerificationControllerProvider.notifier)
          .onOtpChanged,
      onVerify: _verify,
      onResend: _resend,
    );
  }
}
