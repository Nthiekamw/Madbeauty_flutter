import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_account_deletion_screen.dart';
import '../../features/admin/screens/admin_booking_platform_fee_screen.dart';
import '../../features/admin/screens/admin_subscription_trial_screen.dart';
import '../../features/admin/screens/admin_audit_screen.dart';
import '../../features/admin/screens/admin_boutique_orders_screen.dart';
import '../../features/admin/screens/admin_push_screen.dart';
import '../../features/admin/screens/admin_bug_reports_screen.dart';
import '../../features/admin/screens/admin_content_reports_screen.dart';
import '../../features/admin/screens/admin_dispute_detail_screen.dart';
import '../../features/admin/screens/admin_disputes_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/admin/screens/admin_management_hub_screen.dart';
import '../../features/admin/screens/admin_moderation_hub_screen.dart';
import '../../features/admin/screens/admin_profile_screen.dart';
import '../../features/admin/screens/admin_realisation_photos_screen.dart';
import '../../features/admin/screens/admin_reservations_screen.dart';
import '../../features/admin/screens/admin_support_hub_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_user_support_screen.dart';
import '../../features/admin/screens/admin_verification_screen.dart';
import '../app_routes.dart';
import '../shell/admin_shell_scaffold.dart';
import '../shell/shell_route_pages.dart';

List<RouteBase> buildAdminRoutes() => [
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'admin-shell',
        builder: (context, state, navigationShell) => AdminShellScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.adminHome,
                path: AppRoutes.adminHome,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const AdminHomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.adminModeration,
                path: AppRoutes.adminModeration,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const AdminModerationHubScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.adminSupport,
                path: AppRoutes.adminSupport,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const AdminSupportHubScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.adminManagement,
                path: AppRoutes.adminManagement,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const AdminManagementHubScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.adminProfile,
                path: AppRoutes.adminProfile,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const AdminProfileScreen(),
                ),
              ),
            ],
          ),
        ],
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
      GoRoute(
        name: AppRouteNames.adminUsers,
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminAccountDeletions,
        path: AppRoutes.adminAccountDeletions,
        builder: (context, state) => const AdminAccountDeletionScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminReservations,
        path: AppRoutes.adminReservations,
        builder: (context, state) => const AdminReservationsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminBoutiqueOrders,
        path: AppRoutes.adminBoutiqueOrders,
        builder: (context, state) => const AdminBoutiqueOrdersScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminAudit,
        path: AppRoutes.adminAudit,
        builder: (context, state) => const AdminAuditScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminPush,
        path: AppRoutes.adminPush,
        builder: (context, state) => const AdminPushScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminBugReports,
        path: AppRoutes.adminBugReports,
        builder: (context, state) => const AdminBugReportsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminSubscriptionTrial,
        path: AppRoutes.adminSubscriptionTrial,
        builder: (context, state) => const AdminSubscriptionTrialScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminBookingPlatformFee,
        path: AppRoutes.adminBookingPlatformFee,
        builder: (context, state) => const AdminBookingPlatformFeeScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminUserSupport,
        path: AppRoutes.adminUserSupport,
        builder: (context, state) => const AdminUserSupportScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminDisputes,
        path: AppRoutes.adminDisputes,
        builder: (context, state) => const AdminDisputesScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminDisputeDetail,
        path: AppRoutes.adminDisputeDetail,
        builder: (context, state) => AdminDisputeDetailScreen(
          disputeId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        name: AppRouteNames.adminRealisationPhotos,
        path: AppRoutes.adminRealisationPhotos,
        builder: (context, state) => const AdminRealisationPhotosScreen(),
      ),
    ];
