import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../features/auth/providers/auth_notifier.dart';
import '../../features/referral/logic/referral_pending_apply.dart';
import '../../router/app_router.dart';
import '../supabase/profile/profile_providers.dart';
import 'booking_push_notifications.dart';
import '../../features/favorites/providers/client_favorite_prestataire_ids_provider.dart';
import 'in_app_notifications_provider.dart';
import 'push_navigation.dart';

/// À chaque événement d’auth : FCM dans [user_profiles] + liste locale des notifs push.
class BookingPushCoordinator extends ConsumerStatefulWidget {
  const BookingPushCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BookingPushCoordinator> createState() =>
      _BookingPushCoordinatorState();
}

class _BookingPushCoordinatorState
    extends ConsumerState<BookingPushCoordinator> {
  /// Dernier [User.id] vu en session (évite purge quand navigation invité hors compte).
  String? _lastAuthUserIdSeen;

  @override
  void initState() {
    super.initState();
    BookingPushNotifications.instance.setOnInboxMessage((msg) {
      if (!mounted) return;
      ref
          .read(inAppNotificationsProvider.notifier)
          .enqueueFromRemoteMessage(msg);
    });
    BookingPushNotifications.instance.setOnNotificationOpened((msg) {
      if (!mounted) return;
      final router = ref.read(goRouterProvider);
      handlePushMessageNavigationWithRouter(router, msg);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !AppConfig.hasSupabase) return;
      final next = ref.read(authNotifierProvider);
      unawaited(_apply(next));
    });
  }

  Future<void> _apply(AsyncValue<User?> auth) async {
    if (!AppConfig.hasSupabase) return;
    await auth.when(
      data: (user) async {
        final uid = user?.id;

        final wasSignedIn = _lastAuthUserIdSeen != null;
        final isSignedOut = uid == null;
        if (wasSignedIn && isSignedOut) {
          await ref.read(inAppNotificationsProvider.notifier).purgeForLogout();
          await ref
              .read(clientFavoritePrestataireIdsProvider.notifier)
              .purgeForLogout();
        }
        _lastAuthUserIdSeen = uid;

        final profileSvc = ref.read(profileServiceProvider);
        await BookingPushNotifications.instance.syncForUser(
          userId: uid,
          profileService: profileSvc,
        );
        if (uid != null) {
          unawaited(applyPendingReferralCode(ref));
        }
      },
      loading: () async {},
      error: (_, __) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authNotifierProvider, (_, next) {
      unawaited(_apply(next));
    });
    return widget.child;
  }
}
