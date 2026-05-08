import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login/routes/login_route.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/auth/register/routes/register_route.dart';
import '../features/auth/role/screens/role_choice_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/prestataire/screens/prestataire_hub_screen.dart';
import '../features/splash/screens/startup_splash_screen.dart';
import '../services/storage/local_cache_service.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String role = '/role';
  static const String prestataire = '/prestataire';
}

abstract final class AppRouteNames {
  static const String splash = 'splash';
  static const String home = 'home';
  static const String login = 'login';
  static const String register = 'register';
  static const String role = 'role';
  static const String prestataire = 'prestataire';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);

  final user = switch (auth) {
    AsyncData(:final value) => value,
    _ => null,
  };

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final publicRoutes = <String>{
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
      };
      final guestOnlyRoutes = <String>{
        AppRoutes.login,
        AppRoutes.register,
      };
      final requiresAuth = !publicRoutes.contains(location);

      final selectedRole = LocalCacheService.instance.selectedRole;
      final preferredPath = switch (selectedRole) {
        'prestataire' => AppRoutes.prestataire,
        'client' => AppRoutes.home,
        _ => AppRoutes.role,
      };

      if (auth.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (user == null) {
        if (location == AppRoutes.splash) return AppRoutes.login;
        if (requiresAuth) return AppRoutes.login;
        return null;
      }

      if (location == AppRoutes.splash || guestOnlyRoutes.contains(location)) {
        return preferredPath;
      }

      return null;
    },
    routes: [
      GoRoute(
        name: AppRouteNames.splash,
        path: AppRoutes.splash,
        builder: (context, state) => const StartupSplashScreen(),
      ),
      GoRoute(
        name: AppRouteNames.home,
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: AppRouteNames.login,
        path: AppRoutes.login,
        builder: (context, state) => const LoginRoute(),
      ),
      GoRoute(
        name: AppRouteNames.register,
        path: AppRoutes.register,
        builder: (context, state) => const RegisterRoute(),
      ),
      GoRoute(
        name: AppRouteNames.role,
        path: AppRoutes.role,
        builder: (context, state) => const RoleChoiceScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataire,
        path: AppRoutes.prestataire,
        builder: (context, state) => const PrestataireHubScreen(),
      ),
    ],
  );
});
