import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/messaging/screens/conversations_inbox_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/reel/screens/client_reel_feed_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../app_routes.dart';
import '../shell/client_shell_scaffold.dart';
import '../shell/shell_route_pages.dart';

RouteBase buildClientShellRoute() {
  return StatefulShellRoute.indexedStack(
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
            name: AppRouteNames.clientReel,
            path: AppRoutes.clientReel,
            pageBuilder: (context, state) => shellTabPage(
              key: state.pageKey,
              child: ClientReelFeedScreen(
                focusReelId: state.uri.queryParameters['reelId'],
              ),
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
  );
}
