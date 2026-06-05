import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../router/app_router.dart';
import '../providers/auth_notifier.dart';

/// Redirige vers [/reset-password] dès que le deep link recovery est traité.
void listenPasswordRecoveryNavigation(WidgetRef ref) {
  ref.listen<AsyncValue<AuthState>>(authStateStreamProvider, (previous, next) {
    final event = next.value?.event;
    if (event != AuthChangeEvent.passwordRecovery) return;

    final router = ref.read(goRouterProvider);
    final location = router.state.matchedLocation;
    if (location == AppRoutes.resetPassword) return;

    router.go(AppRoutes.resetPassword);
  });
}

