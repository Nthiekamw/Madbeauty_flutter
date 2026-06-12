import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/domain/user_ban_status.dart';
import '../../../router/app_router.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/profile/profile_service.dart';
import '../../../services/supabase/supabase_service.dart';
import '../providers/auth_notifier.dart';
import '../providers/pending_ban_notice_provider.dart';
import '../widgets/feedback/account_banned_dialog.dart';

/// Détection bannissement, déconnexion et retour accueil.
abstract final class AccountBanHandler {
  AccountBanHandler._();

  static Future<UserBanStatus> fetchStatus(String userId) async {
    return ProfileService(SupabaseService.client).getBanStatus(userId);
  }

  /// `true` si l'utilisateur peut continuer (non banni).
  static Future<bool> ensureNotBanned(
    ProviderContainer container, {
    BuildContext? dialogContext,
    GoRouter? router,
  }) async {
    final user = container.read(authNotifierProvider).value;
    if (user == null) return true;

    final status = await fetchStatus(user.id);
    if (!status.isBanned) return true;

    final ctx = dialogContext ??
        router?.routerDelegate.navigatorKey.currentContext ??
        container.read(goRouterProvider).routerDelegate.navigatorKey.currentContext;

    final GoRouter nav = router ?? container.read(goRouterProvider);

    var action = AccountBannedDialogAction.dismiss;
    if (ctx != null && ctx.mounted) {
      action = await AccountBannedDialog.show(ctx, reason: status.reason);
    } else {
      container.read(pendingBanNoticeProvider.notifier).arm(status.reason);
    }

    if (action == AccountBannedDialogAction.contactSupport) {
      final reason = status.reason?.trim();
      await nav.pushNamed(
        AppRouteNames.bannedAccountSupport,
        queryParameters: {
          'flow': 'ban',
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      // La déconnexion est déclenchée à la fermeture de l'écran support (PopScope).
      return false;
    }

    await finishBannedFlow(container, router: nav);
    return false;
  }

  /// Déconnexion + accueil après un refus ou la fin du parcours support.
  static Future<void> finishBannedFlow(
    ProviderContainer container, {
    GoRouter? router,
  }) async {
    final GoRouter nav = router ?? container.read(goRouterProvider);
    if (container.read(authNotifierProvider).value != null) {
      await container.read(authNotifierProvider.notifier).signOut();
    }
    await nav.goNamedDeferred(AppRouteNames.welcome);
  }
}
