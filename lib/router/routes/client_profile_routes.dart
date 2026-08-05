import 'package:go_router/go_router.dart';

import '../../features/booking/screens/client_history_screen.dart';
import '../../features/booking/screens/client_reservations_screen.dart';
import '../../features/cart/screens/client_boutique_cart_screen.dart';
import '../../features/cart/screens/client_boutique_orders_screen.dart';
import '../../features/favorites/screens/client_favorites_screen.dart';
import '../../features/wishlist/screens/client_wishlist_screen.dart';
import '../../features/reel/screens/client_reel_favorites_screen.dart';
import '../../features/bug_report/screens/bug_report_chat_screen.dart';
import '../../features/bug_report/screens/bug_reports_hub_screen.dart';
import '../../features/bug_report/screens/report_bug_screen.dart';
import '../../features/help/screens/help_center_screen.dart';
import '../../features/listing/screens/all_prestataires_screen.dart';
import '../../features/profile/screens/client_payment_methods_screen.dart';
import '../../features/profile/screens/edit_client_account_screen.dart';
import '../../features/referral/screens/referral_screen.dart';
import '../../features/loyalty/screens/loyalty_screen.dart';
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
        name: AppRouteNames.clientReelFavorites,
        path: AppRoutes.clientReelFavorites,
        builder: (context, state) => const ClientReelFavoritesScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientWishlist,
        path: AppRoutes.clientWishlist,
        builder: (context, state) => const ClientWishlistScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientCart,
        path: AppRoutes.clientCart,
        builder: (context, state) => const ClientBoutiqueCartScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientBoutiqueOrders,
        path: AppRoutes.clientBoutiqueOrders,
        builder: (context, state) => const ClientBoutiqueOrdersScreen(),
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
        name: AppRouteNames.clientReservations,
        path: AppRoutes.clientReservations,
        builder: (context, state) => const ClientReservationsScreen(),
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
        name: AppRouteNames.clientReportBug,
        path: AppRoutes.clientReportBug,
        builder: (context, state) => const BugReportsHubScreen(),
        routes: [
          GoRoute(
            name: AppRouteNames.clientNewBugReport,
            path: 'new',
            builder: (context, state) => const ReportBugScreen(),
          ),
        ],
      ),
      GoRoute(
        name: AppRouteNames.clientMyBugReports,
        path: AppRoutes.clientMyBugReports,
        redirect: (context, state) => AppRoutes.clientReportBug,
      ),
      GoRoute(
        name: AppRouteNames.bugReportChat,
        path: AppRoutes.bugReportChat,
        builder: (context, state) => BugReportChatScreen(
          bugReportId: state.pathParameters['id']!,
        ),
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
      GoRoute(
        name: AppRouteNames.clientLoyalty,
        path: AppRoutes.clientLoyalty,
        builder: (context, state) => const LoyaltyScreen(),
      ),
    ];
