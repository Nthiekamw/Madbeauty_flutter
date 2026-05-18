import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/logic/auth_role_cache.dart';
import '../features/auth/forgot_password/routes/forgot_password_route.dart';
import '../features/auth/onboarding/screens/onboarding_screen.dart';
import '../features/auth/login/routes/login_route.dart';
import '../features/auth/welcome/screens/auth_welcome_screen.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/auth/providers/password_recovery_provider.dart';
import '../features/auth/register/routes/register_route.dart';
import '../features/auth/reset_password/routes/reset_password_route.dart';
import '../features/auth/role/screens/role_choice_screen.dart';
import '../features/booking/screens/booking_confirmation_screen.dart';
import '../features/booking/screens/booking_screen.dart';
import '../features/booking/screens/client_reservations_screen.dart';
import '../features/dev/screens/async_state_test_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/prestataire/screens/prestataire_agenda_screen.dart';
import '../features/prestataire/screens/prestataire_dashboard_screen.dart';
import '../features/prestataire/screens/prestataire_detail_screen.dart';
import '../features/prestataire/screens/prestataire_horaires_screen.dart';
import '../features/prestataire/screens/prestataire_hub_screen.dart';
import '../features/profile/screens/become_prestataire_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/splash/screens/startup_splash_screen.dart';
import 'shell/client_shell_scaffold.dart';
import 'shell/prestataire_shell_scaffold.dart';
import 'shell/shell_route_pages.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String role = '/role';
  static const String prestataires = '/prestataires';
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String asyncStateTest = '/test/async-states';
  static const String becomePrestataire = '/become-prestataire';

  static const String clientHome = '/client/home';
  static const String clientSearch = '/client/search';
  static const String clientReservations = '/client/reservations';
  static const String clientProfile = '/client/profile';

  static const String prestataireDashboard = '/prestataire/dashboard';
  static const String prestataireAgenda = '/prestataire/agenda';
  static const String prestataireProfile = '/prestataire/profile';
  static const String prestataireHoraires = '/prestataire/horaires';

  /// Anciennes routes — redirigées vers le shell client / prestataire.
  static const String home = '/';
  static const String listing = '/listing';
  static const String myReservations = '/reservations';
  static const String prestataire = '/prestataire';
}

abstract final class AppRouteNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String role = 'role';
  static const String prestataireDetail = 'prestataire-detail';
  static const String booking = 'booking';
  static const String bookingConfirmation = 'booking-confirmation';
  static const String asyncStateTest = 'async-state-test';
  static const String becomePrestataire = 'become-prestataire';

  static const String clientHome = 'client-home';
  static const String clientSearch = 'client-search';
  static const String clientReservations = 'client-reservations';
  static const String clientProfile = 'client-profile';

  static const String prestataireDashboard = 'prestataire-dashboard';
  static const String prestataireAgenda = 'prestataire-agenda';
  static const String prestataireProfile = 'prestataire-profile';
  static const String prestataireHoraires = 'prestataire-horaires';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);
  final authEvent = switch (ref.watch(authStateStreamProvider)) {
    AsyncData(:final value) => value.event,
    _ => null,
  };
  final recoveryPending =
      ref.watch(passwordRecoveryPendingProvider) ||
      authEvent == AuthChangeEvent.passwordRecovery;

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
        AppRoutes.onboarding,
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
        if (kDebugMode) AppRoutes.asyncStateTest,
      };
      final guestOnlyRoutes = <String>{
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      };

      final preferredPath = AuthRoleCache.preferredAuthenticatedPath();
      final effectiveRole = AuthRoleCache.preferredAuthenticatedRole();

      String? legacyRedirect() {
        return switch (location) {
          AppRoutes.home => preferredPath,
          AppRoutes.listing => AppRoutes.clientSearch,
          AppRoutes.myReservations => AppRoutes.clientReservations,
          AppRoutes.prestataire when effectiveRole == 'prestataire' =>
            AppRoutes.prestataireProfile,
          AppRoutes.prestataire => AppRoutes.clientHome,
          _ => null,
        };
      }

      final legacy = legacyRedirect();
      if (legacy != null) return legacy;

      if (auth.isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (recoveryPending) {
        if (location != AppRoutes.resetPassword) {
          return AppRoutes.resetPassword;
        }
        return null;
      }

      if (location == AppRoutes.resetPassword) {
        return user == null ? AppRoutes.login : preferredPath;
      }

      if (user == null) {
        if (publicRoutes.contains(location)) return null;
        return AppRoutes.welcome;
      }

      if (location == AppRoutes.splash ||
          location == AppRoutes.onboarding ||
          location == AppRoutes.welcome ||
          guestOnlyRoutes.contains(location)) {
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
        name: AppRouteNames.onboarding,
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: AppRouteNames.welcome,
        path: AppRoutes.welcome,
        builder: (context, state) => const AuthWelcomeScreen(),
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
        name: AppRouteNames.forgotPassword,
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordRoute(),
      ),
      GoRoute(
        name: AppRouteNames.resetPassword,
        path: AppRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordRoute(),
      ),
      GoRoute(
        name: AppRouteNames.role,
        path: AppRoutes.role,
        builder: (context, state) => const RoleChoiceScreen(),
      ),
      GoRoute(
        name: AppRouteNames.becomePrestataire,
        path: AppRoutes.becomePrestataire,
        builder: (context, state) => const BecomePrestataireScreen(),
      ),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'client-shell',
        builder: (context, state, navigationShell) => ClientShellScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.clientHome,
                path: AppRoutes.clientHome,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.clientSearch,
                path: AppRoutes.clientSearch,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const SearchScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.clientReservations,
                path: AppRoutes.clientReservations,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const ClientReservationsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.clientProfile,
                path: AppRoutes.clientProfile,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'prestataire-shell',
        builder: (context, state, navigationShell) => PrestataireShellScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.prestataireDashboard,
                path: AppRoutes.prestataireDashboard,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const PrestataireDashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.prestataireAgenda,
                path: AppRoutes.prestataireAgenda,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const PrestataireAgendaScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.prestataireProfile,
                path: AppRoutes.prestataireProfile,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const PrestataireHubScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: AppRouteNames.prestataireDetail,
        path: '${AppRoutes.prestataires}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PrestataireDetailScreen(prestataireId: id);
        },
      ),
      GoRoute(
        name: AppRouteNames.booking,
        path: AppRoutes.booking,
        builder: (context, state) => BookingScreen(
          prestataireId: state.uri.queryParameters['prestataireId'],
          serviceId: state.uri.queryParameters['serviceId'],
        ),
      ),
      GoRoute(
        name: AppRouteNames.bookingConfirmation,
        path: AppRoutes.bookingConfirmation,
        builder: (context, state) {
          final params = state.uri.queryParameters;
          final dateTime =
              DateTime.tryParse(params['dateTime'] ?? '') ?? DateTime.now();
          return BookingConfirmationScreen(
            prestataireId: params['prestataireId'] ?? '',
            serviceId: params['serviceId'] ?? '',
            serviceName: params['serviceName'] ?? '',
            price: double.tryParse(params['price'] ?? '') ?? 0,
            durationMinutes: int.tryParse(params['durationMinutes'] ?? '') ?? 0,
            dateTime: dateTime,
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.asyncStateTest,
        path: AppRoutes.asyncStateTest,
        builder: (context, state) => const AsyncStateTestScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireHoraires,
        path: AppRoutes.prestataireHoraires,
        builder: (context, state) => const PrestataireHorairesScreen(),
      ),
    ],
  );
});
