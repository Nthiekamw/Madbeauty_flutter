import 'package:go_router/go_router.dart';

import '../../features/auth/screens/banned_account_support_screen.dart';
import '../../features/auth/forgot_password/routes/forgot_password_route.dart';
import '../../features/auth/login/routes/login_route.dart';
import '../../features/auth/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/register/routes/register_route.dart';
import '../../features/auth/register/screens/register_email_verification_screen.dart';
import '../../features/auth/reset_password/routes/reset_password_route.dart';
import '../../features/auth/role/screens/role_choice_screen.dart';
import '../../features/auth/welcome/screens/auth_welcome_screen.dart';
import '../../features/profile/screens/become_prestataire_screen.dart';
import '../../features/splash/screens/startup_splash_screen.dart';
import '../app_routes.dart';

List<RouteBase> buildAuthRoutes() => [
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
        name: AppRouteNames.registerVerifyEmail,
        path: AppRoutes.registerVerifyEmail,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return RegisterEmailVerificationScreen(email: email);
        },
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
        name: AppRouteNames.bannedAccountSupport,
        path: AppRoutes.bannedAccountSupport,
        builder: (context, state) => BannedAccountSupportScreen(
          banReason: state.uri.queryParameters['reason'],
          banAppealFlow: state.uri.queryParameters['flow'] == 'ban',
        ),
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
    ];
