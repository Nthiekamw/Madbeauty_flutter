import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_subscription_trial_screen.dart';
import '../../features/admin/screens/admin_audit_screen.dart';
import '../../features/admin/screens/admin_push_screen.dart';
import '../../features/admin/screens/admin_bug_reports_screen.dart';
import '../../features/admin/screens/admin_content_reports_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/admin/screens/admin_profile_screen.dart';
import '../../features/admin/screens/admin_reservations_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
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
                name: AppRouteNames.adminVerifications,
                path: AppRoutes.adminVerifications,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const AdminVerificationScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: AppRouteNames.adminReports,
                path: AppRoutes.adminReports,
                pageBuilder: (context, state) => shellTabPage(
                  key: state.pageKey,
                  child: const AdminContentReportsScreen(),
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
        name: AppRouteNames.adminUsers,
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        name: AppRouteNames.adminReservations,
        path: AppRoutes.adminReservations,
        builder: (context, state) => const AdminReservationsScreen(),
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
    ];
