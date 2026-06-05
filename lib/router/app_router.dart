import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/logic/auth_role_cache.dart';
import '../features/auth/forgot_password/routes/forgot_password_route.dart';
import '../features/auth/onboarding/screens/onboarding_screen.dart';
import '../features/auth/login/routes/login_route.dart';
import '../features/auth/welcome/screens/auth_welcome_screen.dart';
import '../features/auth/guest/guest_mode_provider.dart';
import '../features/auth/guest/guest_route_policy.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/auth/providers/my_roles_provider.dart';
import '../features/auth/providers/password_recovery_provider.dart'
    show isPasswordRecoveryActiveProvider;
import '../features/auth/register/routes/register_route.dart';
import '../features/auth/register/screens/register_email_verification_screen.dart';
import '../features/auth/register/storage/register_wizard_draft_store.dart';
import '../features/auth/reset_password/routes/reset_password_route.dart';
import '../features/auth/role/screens/role_choice_screen.dart';
import '../features/booking/screens/booking_confirmation_screen.dart';
import '../features/booking/screens/booking_screen.dart';
import '../features/booking/screens/client_history_screen.dart';
import '../features/booking/screens/client_reservation_detail_screen.dart';
import '../features/booking/screens/client_reservations_screen.dart';
import '../features/dev/screens/async_state_test_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/prestataire/screens/prestataire_agenda_screen.dart';
import '../features/prestataire/screens/prestataire_dashboard_screen.dart';
import '../features/prestataire/screens/prestataire_history_screen.dart';
import '../features/prestataire/screens/prestataire_reservation_detail_screen.dart';
import '../features/prestataire/screens/prestataire_detail_screen.dart';
import '../features/prestataire/screens/prestataire_horaires_screen.dart';
import '../features/prestataire/models/prestataire_profile_edit_section.dart';
import '../features/prestataire/screens/prestataire_hub_screen.dart';
import '../features/prestataire/screens/prestataire_profile_screen.dart';
import '../features/prestataire/screens/prestataire_payment_methods_screen.dart';
import '../features/prestataire/screens/prestataire_subscription_screen.dart';
import '../features/profile/screens/become_prestataire_screen.dart';
import '../features/favorites/screens/client_favorites_screen.dart';
import '../features/messaging/screens/chat_screen.dart';
import '../features/messaging/screens/conversations_inbox_screen.dart';
import '../features/reviews/screens/client_reviews_screen.dart';
import '../features/admin/screens/admin_content_reports_screen.dart';
import '../features/admin/screens/admin_verification_screen.dart';
import '../services/storage/local_cache_service.dart';
import '../services/supabase/messaging/messaging_providers.dart';
import '../features/profile/screens/client_payment_methods_screen.dart';
import '../features/profile/screens/edit_client_account_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/help/screens/help_center_screen.dart';
import '../features/referral/screens/referral_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/splash/screens/startup_splash_screen.dart';
import 'app_deep_links.dart';
import 'prestataire_public_route.dart';
import 'shell/client_shell_scaffold.dart';
import 'shell/prestataire_shell_scaffold.dart';
import 'shell/shell_route_pages.dart';

abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerVerifyEmail = '/register/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String role = '/role';
  /// Fiche publique partageable : `/prestataire/:id` (UUID).
  static const String prestatairePublicProfile = '/prestataire';

  /// Ancien chemin listing — redirigé vers [prestatairePublicProfile].
  static const String prestatairesLegacy = '/prestataires';
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String asyncStateTest = '/test/async-states';
  static const String becomePrestataire = '/become-prestataire';

  static const String clientHome = '/client/home';
  static const String clientSearch = '/client/search';
  static const String clientReservations = '/client/reservations';
  static const String clientReservationDetail = '/client/reservations/:id';
  static const String clientMessages = '/client/messages';
  static const String clientProfile = '/client/profile';
  static const String chat = '/chat';
  static const String editClientAccount = '/client/profile/edit';
  static const String clientPaymentMethods = '/client/payment-methods';
  static const String clientFavorites = '/client/favorites';
  static const String clientReviews = '/client/reviews';
  static const String clientHistory = '/client/history';
  static const String clientHelp = '/client/help';
  static const String clientReferral = '/client/referral';
  static const String adminVerifications = '/admin/verifications';
  static const String adminReports = '/admin/reports';

  static const String prestataireDashboard = '/prestataire/dashboard';
  static const String prestataireAgenda = '/prestataire/agenda';
  static const String prestataireProfile = '/prestataire/profile';
  static const String prestataireClients = '/prestataire/clients';
  static const String prestataireMessages = '/prestataire/messages';
  static const String prestataireReservationDetail =
      '/prestataire/reservations/:id';
  static const String prestataireProfileEdit = '/prestataire/profile/edit';
  static const String prestataireHoraires = '/prestataire/horaires';
  static const String prestataireSubscription = '/prestataire/subscription';
  static const String prestatairePaymentMethods = '/prestataire/payment-methods';

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
  static const String registerVerifyEmail = 'register-verify-email';
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
  static const String clientReservationDetail = 'client-reservation-detail';
  static const String clientMessages = 'client-messages';
  static const String clientProfile = 'client-profile';
  static const String chat = 'chat';
  static const String editClientAccount = 'edit-client-account';
  static const String clientPaymentMethods = 'client-payment-methods';
  static const String clientFavorites = 'client-favorites';
  static const String clientReviews = 'client-reviews';
  static const String clientHistory = 'client-history';
  static const String clientHelp = 'client-help';
  static const String clientReferral = 'client-referral';
  static const String adminVerifications = 'admin-verifications';
  static const String adminReports = 'admin-reports';

  static const String prestataireDashboard = 'prestataire-dashboard';
  static const String prestataireAgenda = 'prestataire-agenda';
  static const String prestataireProfile = 'prestataire-profile';
  static const String prestataireClients = 'prestataire-clients';
  static const String prestataireMessages = 'prestataire-messages';
  static const String prestataireReservationDetail =
      'prestataire-reservation-detail';
  static const String prestataireProfileEdit = 'prestataire-profile-edit';
  static const String prestataireHoraires = 'prestataire-horaires';
  static const String prestataireSubscription = 'prestataire-subscription';
  static const String prestatairePaymentMethods = 'prestataire-payment-methods';
}

/// Recalcule les [redirect] sans recréer [GoRouter] (évite le double clic invité).
final routerRefreshListenableProvider = Provider<Listenable>((ref) {
  final notifier = ValueNotifier<int>(0);
  void bump() => notifier.value++;

  ref.listen(authNotifierProvider, (_, __) => bump());
  ref.listen(guestModeProvider, (_, __) => bump());
  ref.listen(isPasswordRecoveryActiveProvider, (_, __) => bump());

  ref.onDispose(notifier.dispose);
  return notifier;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final recoveryActive = ref.read(isPasswordRecoveryActiveProvider);
      final guestMode = ref.read(guestModeProvider);

      final user = switch (auth) {
        AsyncData(:final value) => value,
        _ => null,
      };

      final location = state.matchedLocation;
      final publicRoutes = <String>{
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.registerVerifyEmail,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
        if (kDebugMode) AppRoutes.asyncStateTest,
      };
      final guestOnlyRoutes = <String>{
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.registerVerifyEmail,
        AppRoutes.forgotPassword,
      };

      final preferredPath = AuthRoleCache.preferredAuthenticatedPath();
      final effectiveRole = AuthRoleCache.preferredAuthenticatedRole();
      final hasAdminRole = ref
          .read(myRolesProvider)
          .maybeWhen(
            data: (roles) => roles.any((r) => r.value == 'admin'),
            orElse: () => false,
          );

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

      final sharedProfile = AppDeepLinks.legacyListingRedirect(location);
      if (sharedProfile != null) return sharedProfile;

      if (auth.isLoading) {
        // Ne pas interrompre l’inscription : signUp met auth en loading et
        // sinon le splash relance PostAuthNavigation avant ensureRole(prestataire).
        if (location == AppRoutes.register) return null;
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (recoveryActive) {
        if (location != AppRoutes.resetPassword) {
          return AppRoutes.resetPassword;
        }
        return null;
      }

      if (location == AppRoutes.resetPassword) {
        if (user == null) return AppRoutes.login;
        return null;
      }

      final registerDraftPending =
          RegisterWizardDraftStore.instance.hasDraft;

      if (user == null) {
        if (guestMode) {
          if (GuestRoutePolicy.requiresAccount(location)) {
            return location == AppRoutes.bookingConfirmation
                ? AppRoutes.login
                : AppRoutes.clientHome;
          }
          if (GuestRoutePolicy.isBrowsableAsGuest(location)) return null;
        }
        if (publicRoutes.contains(location)) return null;
        return AppRoutes.welcome;
      }

      final registerWizardOngoing = registerDraftPending ||
          (RegisterWizardDraftStore.instance.read()?.signedUpViaOAuth ?? false);

      if (location == AppRoutes.register && registerWizardOngoing) {
        return null;
      }

      // Le splash exécute PostAuthNavigation après sync des rôles serveur.
      if (location == AppRoutes.splash) {
        return null;
      }

      if (location == AppRoutes.onboarding ||
          location == AppRoutes.welcome ||
          guestOnlyRoutes.contains(location)) {
        return preferredPath;
      }

      if ((location.startsWith(AppRoutes.adminVerifications) ||
              location.startsWith(AppRoutes.adminReports)) &&
          !hasAdminRole) {
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
        name: AppRouteNames.role,
        path: AppRoutes.role,
        builder: (context, state) => const RoleChoiceScreen(),
      ),
      GoRoute(
        name: AppRouteNames.becomePrestataire,
        path: AppRoutes.becomePrestataire,
        builder: (context, state) => const BecomePrestataireScreen(),
      ),
      GoRoute(
        name: AppRouteNames.editClientAccount,
        path: AppRoutes.editClientAccount,
        builder: (context, state) => const EditClientAccountScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientPaymentMethods,
        path: AppRoutes.clientPaymentMethods,
        builder: (context, state) => const ClientPaymentMethodsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientFavorites,
        path: AppRoutes.clientFavorites,
        builder: (context, state) => const ClientFavoritesScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientReviews,
        path: AppRoutes.clientReviews,
        builder: (context, state) => const ClientReviewsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientHistory,
        path: AppRoutes.clientHistory,
        builder: (context, state) => const ClientHistoryScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientHelp,
        path: AppRoutes.clientHelp,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientReferral,
        path: AppRoutes.clientReferral,
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          if (code != null && code.trim().isNotEmpty) {
            // Stocké pour application auto sur l’écran parrainage.
            LocalCacheService.instance.setPendingReferralCode(code.trim());
          }
          return const ReferralScreen();
        },
      ),
      GoRoute(
        name: AppRouteNames.adminVerifications,
        path: AppRoutes.adminVerifications,
        builder: (context, state) => const AdminVerificationScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminReports,
        path: AppRoutes.adminReports,
        builder: (context, state) => const AdminContentReportsScreen(),
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
                name: AppRouteNames.clientMessages,
                path: AppRoutes.clientMessages,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const ConversationsInboxScreen(
                    role: MessagingInboxRole.client,
                  ),
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
                name: AppRouteNames.prestataireClients,
                path: AppRoutes.prestataireClients,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const PrestataireHistoryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.prestataireMessages,
                path: AppRoutes.prestataireMessages,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const ConversationsInboxScreen(
                    role: MessagingInboxRole.prestataire,
                  ),
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
                  child: const PrestataireProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        name: AppRouteNames.chat,
        path: '${AppRoutes.chat}/:bookingId',
        builder: (context, state) {
          final id = state.pathParameters['bookingId']!;
          return ChatScreen(bookingId: id);
        },
      ),
      GoRoute(
        name: AppRouteNames.clientReservationDetail,
        path: AppRoutes.clientReservationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ClientReservationDetailScreen(reservationId: id);
        },
      ),
      GoRoute(
        name: AppRouteNames.prestataireReservationDetail,
        path: AppRoutes.prestataireReservationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PrestataireReservationDetailScreen(reservationId: id);
        },
      ),
      // Routes statiques AVANT `/prestataire/:id` (sinon `subscription`, `horaires`, etc.
      // sont pris pour un UUID fiche publique).
      GoRoute(
        name: AppRouteNames.prestataireHoraires,
        path: AppRoutes.prestataireHoraires,
        builder: (context, state) => const PrestataireHorairesScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireSubscription,
        path: AppRoutes.prestataireSubscription,
        builder: (context, state) => const PrestataireSubscriptionScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestatairePaymentMethods,
        path: AppRoutes.prestatairePaymentMethods,
        builder: (context, state) => const PrestatairePaymentMethodsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireProfileEdit,
        path: AppRoutes.prestataireProfileEdit,
        builder: (context, state) {
          final section = PrestataireProfileEditSection.fromQuery(
            state.uri.queryParameters['section'],
          );
          final stepRaw = state.uri.queryParameters['step'];
          final initialStep = stepRaw != null ? int.tryParse(stepRaw) : null;
          return PrestataireHubScreen(
            focusedSection: section,
            initialStep: initialStep,
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.prestataireDetail,
        path: '${AppRoutes.prestatairePublicProfile}/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id']?.trim() ?? '';
          if (isPublicPrestataireId(id)) return null;
          return switch (id) {
            'subscription' => AppRoutes.prestataireSubscription,
            'payment-methods' => AppRoutes.prestatairePaymentMethods,
            'horaires' => AppRoutes.prestataireHoraires,
            _ => AppRoutes.clientSearch,
          };
        },
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
          initialDay: state.uri.queryParameters['date'],
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
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
