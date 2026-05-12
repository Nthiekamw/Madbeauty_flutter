import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../providers/auth_notifier.dart';
import '../models/register_view_state.dart';
import '../providers/register_controller.dart';
import '../screens/register_page.dart';

class RegisterRoute extends ConsumerStatefulWidget {
  const RegisterRoute({super.key});

  @override
  ConsumerState<RegisterRoute> createState() => _RegisterRouteState();
}

class _RegisterRouteState extends ConsumerState<RegisterRoute> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await ref.read(registerControllerProvider.notifier).submit(
          rawName: _nameController.text,
          rawEmail: _emailController.text,
          rawPassword: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RegisterViewState>(registerControllerProvider, (previous, next) {
      if (next.requestSupabaseSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ShellStrings.supabaseMissingTitle)),
        );
        ref
            .read(registerControllerProvider.notifier)
            .acknowledgeSupabaseSnack();
      }
      if (next.shouldPopRoute) {
        if (context.mounted) {
          context.goRoleChoice();
        }
        ref.read(registerControllerProvider.notifier).acknowledgeRouteClose();
      }
    });

    final registerUi = ref.watch(registerControllerProvider);
    final authAsync = ref.watch(authNotifierProvider);
    final isLoading = authAsync.isLoading;
    final formEnabled = AppConfig.hasSupabase && !isLoading;

    return RegisterPage(
      showSupabaseConfigCard: !AppConfig.hasSupabase,
      nameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      nameError: registerUi.nameError,
      emailError: registerUi.emailError,
      passwordError: registerUi.passwordError,
      submitError: registerUi.submitError,
      isLoading: isLoading,
      formEnabled: formEnabled,
      onBack: () =>
          context.canPop() ? context.pop() : context.goLogin(),
      onSubmit: _submit,
      onPasswordFieldSubmitted: _submit,
      onNameChanged:
          ref.read(registerControllerProvider.notifier).onNameChanged,
      onEmailChanged:
          ref.read(registerControllerProvider.notifier).onEmailChanged,
      onPasswordChanged:
          ref.read(registerControllerProvider.notifier).onPasswordChanged,
      onOpenLogin: context.goLogin,
    );
  }
}
