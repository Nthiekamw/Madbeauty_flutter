import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/auth_notifier.dart';
import '../models/login_view_state.dart';
import '../providers/login_controller.dart';
import '../screens/login_page.dart';

/// Entrée route `/login` : Riverpod, navigation et [SnackBar] (hors design).
///
/// La page visuelle est [LoginPage] ; la logique dans [LoginController].
class LoginRoute extends ConsumerStatefulWidget {
  const LoginRoute({super.key});

  @override
  ConsumerState<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends ConsumerState<LoginRoute> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref.read(loginControllerProvider.notifier).submit(
          rawEmail: _emailController.text,
          rawPassword: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginViewState>(loginControllerProvider, (previous, next) {
      if (next.requestSupabaseSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.supabaseMissingTitle)),
        );
        ref.read(loginControllerProvider.notifier).acknowledgeSupabaseSnack();
      }
      if (next.shouldPopRoute) {
        if (context.mounted) {
          context.canPop() ? context.pop() : context.go('/');
        }
        ref.read(loginControllerProvider.notifier).acknowledgeRouteClose();
      }
    });

    final loginUi = ref.watch(loginControllerProvider);
    final authAsync = ref.watch(authNotifierProvider);
    final isLoading = authAsync.isLoading;
    final formEnabled = AppConfig.hasSupabase && !isLoading;

    return LoginPage(
      showSupabaseConfigCard: !AppConfig.hasSupabase,
      emailController: _emailController,
      passwordController: _passwordController,
      emailError: loginUi.emailError,
      passwordError: loginUi.passwordError,
      submitError: loginUi.submitError,
      isLoading: isLoading,
      formEnabled: formEnabled,
      onBack: () => context.canPop() ? context.pop() : context.go('/'),
      onSubmit: _submit,
      onPasswordFieldSubmitted: _submit,
    );
  }
}
