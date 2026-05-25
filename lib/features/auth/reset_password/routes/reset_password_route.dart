import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../router/navigation_extensions.dart';
import '../../navigation/post_auth_navigation.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/password_recovery_provider.dart';
import '../logic/reset_password_validators.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../screens/reset_password_page.dart';

class ResetPasswordRoute extends ConsumerStatefulWidget {
  const ResetPasswordRoute({super.key});

  @override
  ConsumerState<ResetPasswordRoute> createState() => _ResetPasswordRouteState();
}

class _ResetPasswordRouteState extends ConsumerState<ResetPasswordRoute> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _passwordError;
  String? _confirmError;
  String? _submitError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final p = _passwordController.text;
    final c = _confirmController.text;
    final pErr = ResetPasswordValidators.password(p);
    final cErr = ResetPasswordValidators.confirmation(p, c);
    setState(() {
      _passwordError = pErr;
      _confirmError = cErr;
      _submitError = null;
    });
    if (pErr != null || cErr != null) return;

    if (!AppConfig.hasSupabase) {
      if (mounted) {
        AppSnackBar.warning(context, ShellStrings.supabaseMissingTitle);
      }
      return;
    }

    await ref.read(authNotifierProvider.notifier).updatePassword(p);
    if (!mounted) return;

    final auth = ref.read(authNotifierProvider);
    if (auth.hasError) {
      final err = auth.error;
      setState(() {
        _submitError =
            err is AppFailure ? err.message : CoreStrings.errorUnexpected;
      });
      return;
    }

    ref.read(passwordRecoveryPendingProvider.notifier).clear();
    if (!mounted) return;

    AppSnackBar.success(context, AuthStrings.resetPasswordSuccess);

    await PostAuthNavigation.navigate(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    final recoveryActive = ref.watch(isPasswordRecoveryActiveProvider);
    final isLoading = authAsync.isLoading;
    final formEnabled = AppConfig.hasSupabase && !isLoading && recoveryActive;

    if (authAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!recoveryActive) {
      return ResetPasswordInvalidLinkPage(
        onRequestNewLink: () => context.pushForgotPassword(),
        onBackToLogin: () => context.goLogin(),
      );
    }

    return ResetPasswordPage(
      passwordController: _passwordController,
      confirmController: _confirmController,
      passwordError: _passwordError,
      confirmError: _confirmError,
      submitError: _submitError,
      isLoading: isLoading,
      formEnabled: formEnabled,
      onSubmit: _submit,
      onPasswordChanged: (_) {
        setState(() {
          _passwordError = null;
          _submitError = null;
        });
      },
      onConfirmChanged: (_) {
        setState(() {
          _confirmError = null;
          _submitError = null;
        });
      },
    );
  }
}
