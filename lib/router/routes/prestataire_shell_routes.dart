import 'package:go_router/go_router.dart';

import '../../features/messaging/screens/conversations_inbox_screen.dart';
import '../../features/prestataire/screens/prestataire_agenda_screen.dart';
import '../../features/prestataire/screens/prestataire_dashboard_screen.dart';
import '../../features/prestataire/screens/prestataire_history_screen.dart';
import '../../features/prestataire/screens/prestataire_profile_screen.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../app_routes.dart';
import '../shell/prestataire_shell_scaffold.dart';
import '../shell/shell_route_pages.dart';

RouteBase buildPrestataireShellRoute() {
  return StatefulShellRoute.indexedStack(
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
  );
}
