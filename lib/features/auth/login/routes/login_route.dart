import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/auth_notifier.dart';
import '../models/login_view_state.dart';
import '../providers/login_controller.dart';
import '../screens/login_page.dart';

class LoginRoute extends ConsumerStatefulWidget {
  const LoginRoute({super.key});

  @override
  ConsumerState<LoginRoute> createState() => _LoginRouteState();
}

class _LoginRouteState extends ConsumerState<LoginRoute> {
  final _emailController    = TextEditingController();
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

  // Connexion → redirige selon le rôle en base
  Future<void> _redirectAfterLogin() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = data['role'] as String?;
      if (!mounted) return;

      if (role == 'provider') {
        context.go('/prestataire');  // 👈 prestataire → hub pro
      } else {
        context.go('/client');       // 👈 client → hub client
      }
    } catch (_) {
      if (mounted) context.go('/client');
    }
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
        _redirectAfterLogin();
        ref.read(loginControllerProvider.notifier).acknowledgeRouteClose();
      }
    });

    final loginUi     = ref.watch(loginControllerProvider);
    final authAsync   = ref.watch(authNotifierProvider);
    final isLoading   = authAsync.isLoading;
    final formEnabled = AppConfig.hasSupabase && !isLoading;

    return LoginPage(
      showSupabaseConfigCard:   !AppConfig.hasSupabase,
      emailController:          _emailController,
      passwordController:       _passwordController,
      emailError:               loginUi.emailError,
      passwordError:            loginUi.passwordError,
      submitError:              loginUi.submitError,
      isLoading:                isLoading,
      formEnabled:              formEnabled,
      onBack: () => context.canPop() ? context.pop() : context.go('/'),
      onSubmit:                 _submit,
      onPasswordFieldSubmitted: _submit,
      onRegisterAsProvider: () => context.go('/prestataire/onboarding'),
      onRegisterAsClient:   () => context.go('/client'),  // 👈 corrigé
    );
  }
}






































// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';

// import '../../../../core/config/app_config.dart';
// import '../../../../core/constants/app_strings.dart';
// import '../../providers/auth_notifier.dart';
// import '../models/login_view_state.dart';
// import '../providers/login_controller.dart';
// import '../screens/login_page.dart';

// /// Entrée route `/login` : Riverpod, navigation et [SnackBar] (hors design).
// ///
// /// La page visuelle est [LoginPage] ; la logique dans [LoginController].
// class LoginRoute extends ConsumerStatefulWidget {
//   const LoginRoute({super.key});

//   @override
//   ConsumerState<LoginRoute> createState() => _LoginRouteState();
// }

// class _LoginRouteState extends ConsumerState<LoginRoute> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     FocusScope.of(context).unfocus();
//     await ref.read(loginControllerProvider.notifier).submit(
//           rawEmail: _emailController.text,
//           rawPassword: _passwordController.text,
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     ref.listen<LoginViewState>(loginControllerProvider, (previous, next) {
//       if (next.requestSupabaseSnack) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(AppStrings.supabaseMissingTitle)),
//         );
//         ref.read(loginControllerProvider.notifier).acknowledgeSupabaseSnack();
//       }
//       if (next.shouldPopRoute) {
//         if (context.mounted) {
//           context.canPop() ? context.pop() : context.go('/');
//         }
//         ref.read(loginControllerProvider.notifier).acknowledgeRouteClose();
//       }
//     });

//     final loginUi = ref.watch(loginControllerProvider);
//     final authAsync = ref.watch(authNotifierProvider);
//     final isLoading = authAsync.isLoading;
//     final formEnabled = AppConfig.hasSupabase && !isLoading;

//     return LoginPage(
//       showSupabaseConfigCard: !AppConfig.hasSupabase,
//       emailController: _emailController,
//       passwordController: _passwordController,
//       emailError: loginUi.emailError,
//       passwordError: loginUi.passwordError,
//       submitError: loginUi.submitError,
//       isLoading: isLoading,
//       formEnabled: formEnabled,
//       onBack: () => context.canPop() ? context.pop() : context.go('/'),
//       onSubmit: _submit,
//       onPasswordFieldSubmitted: _submit,
//     );
//   }
// }
