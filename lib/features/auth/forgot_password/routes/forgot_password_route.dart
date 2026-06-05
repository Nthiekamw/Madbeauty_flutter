import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../guest/guest_mode_provider.dart';
import '../../login/logic/login_validators.dart';
import '../../providers/auth_notifier.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../screens/forgot_password_page.dart';

class ForgotPasswordRoute extends ConsumerStatefulWidget {
  const ForgotPasswordRoute({super.key});

  @override
  ConsumerState<ForgotPasswordRoute> createState() =>
      _ForgotPasswordRouteState();
}

class _ForgotPasswordRouteState extends ConsumerState<ForgotPasswordRoute> {
  final _emailController = TextEditingController();
  String? _emailError;
  String? _submitError;
  String? _successMessage;
  bool _loading = false;

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
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final err = LoginValidators.email(email);
    setState(() {
      _emailError = err;
      _submitError = null;
      _successMessage = null;
    });
    if (err != null) return;

    if (!AppConfig.hasSupabase) {
      if (mounted) {
        AppSnackBar.warning(context, ShellStrings.supabaseMissingTitle);
      }
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).resetPasswordForEmail(
            email,
            redirectTo: AppConfig.authEmailRedirectTo,
          );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _successMessage = AuthStrings.forgotPasswordSuccess;
      });
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _submitError = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _submitError = CoreStrings.errorUnexpected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formEnabled = AppConfig.hasSupabase && !_loading;

    return ForgotPasswordPage(
      emailController: _emailController,
      emailError: _emailError,
      submitError: _submitError,
      successMessage: _successMessage,
      isLoading: _loading,
      formEnabled: formEnabled,
      onBack: () => context.pop(),
      onSubmit: _submit,
      onEmailChanged: (_) {
        setState(() {
          _emailError = null;
          _submitError = null;
        });
      },
    );
  }
}

