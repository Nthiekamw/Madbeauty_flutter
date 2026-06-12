import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/guest/guest_mode_provider.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/auth/providers/password_recovery_provider.dart'
    show isPasswordRecoveryActiveProvider;
import 'app_router_redirect.dart';
import 'app_routes.dart';
import 'routes/admin_routes.dart';
import 'routes/auth_routes.dart';
import 'routes/booking_routes.dart';
import 'routes/client_profile_routes.dart';
import 'routes/client_shell_routes.dart';
import 'routes/detail_routes.dart';
import 'routes/prestataire_shell_routes.dart';

export 'app_routes.dart';

/// Recalcule les [redirect] sans recréer [GoRouter] (évite le double clic invité).
final routerRefreshListenableProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  void bump() => notifier.value++;

  ref.listen(authNotifierProvider, (previous, next) {
    final wasSignedIn = switch (previous) {
      AsyncData(:final value) => value != null,
      _ => false,
    };
    final isSignedIn = switch (next) {
      AsyncData(:final value) => value != null,
      _ => false,
    };
    // Connexion : navigation explicite (login / splash). Déconnexion : redirect.
    if (wasSignedIn && !isSignedIn) bump();
  });
  ref.listen(guestModeProvider, (_, __) => bump());
  ref.listen(isPasswordRecoveryActiveProvider, (_, __) => bump());

  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Force un recalcul du redirect (ex. fin du dialogue de bienvenue login).
final routerRedirectBumpProvider = Provider<void Function()>((ref) {
  final notifier = ref.watch(routerRefreshListenableProvider);
  return () => notifier.value++;
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerRefreshListenableProvider);

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    redirect: (context, state) => appRouterRedirect(ref, state),
    routes: [
      ...buildAuthRoutes(),
      ...buildClientProfileRoutes(),
      ...buildAdminRoutes(),
      buildClientShellRoute(),
      buildPrestataireShellRoute(),
      ...buildDetailRoutes(),
      ...buildBookingRoutes(),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
