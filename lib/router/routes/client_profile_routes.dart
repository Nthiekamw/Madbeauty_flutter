import 'package:go_router/go_router.dart';

import '../../features/booking/screens/client_history_screen.dart';
import '../../features/favorites/screens/client_favorites_screen.dart';
import '../../features/help/screens/help_center_screen.dart';
import '../../features/listing/screens/all_prestataires_screen.dart';
import '../../features/profile/screens/client_payment_methods_screen.dart';
import '../../features/profile/screens/edit_client_account_screen.dart';
import '../../features/referral/screens/referral_screen.dart';
import '../../features/reviews/screens/client_reviews_screen.dart';
import '../../services/storage/local_cache_service.dart';
import '../app_routes.dart';

List<RouteBase> buildClientProfileRoutes() => [
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
        name: AppRouteNames.clientAllPrestataires,
        path: AppRoutes.clientAllPrestataires,
        builder: (context, state) => const AllPrestatairesScreen(),
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
            LocalCacheService.instance.setPendingReferralCode(code.trim());
          }
          return const ReferralScreen();
        },
      ),
    ];
