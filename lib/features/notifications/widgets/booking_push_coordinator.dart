import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/booking/providers/booking_session_providers.dart'
    show clientReservationsProvider, invalidateClientReservations;
import '../../../features/prestataire/providers/agenda/prestataire_agenda_provider.dart';
import '../../../features/favorites/providers/client_favorite_prestataire_ids_provider.dart';
import '../../../features/referral/logic/referral_pending_apply.dart';
import '../../../router/app_router.dart';
import '../../../services/notifications/booking_push_notifications.dart';
import '../../../services/notifications/booking_reminders_sync.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/notifications/push_navigation.dart'
    show
        handlePushMessageNavigationWithRouter,
        navigateFromPushDataWithRouter;
import '../../../services/supabase/profile/profile_providers.dart';

/// À chaque événement d'auth : FCM dans [user_profiles] + liste locale des notifs push.
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
      unawaited(_onBookingPushSideEffects(msg));
    });
    BookingPushNotifications.instance.setOnNotificationOpened((msg) {
      if (!mounted) return;
      final router = ref.read(goRouterProvider);
      handlePushMessageNavigationWithRouter(router, msg);
    });
    BookingPushNotifications.instance.setOnPushDataOpened((data) {
      if (!mounted) return;
      final router = ref.read(goRouterProvider);
      navigateFromPushDataWithRouter(router, data);
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
          ref.invalidate(inAppNotificationsSyncProvider);
          unawaited(ref.read(inAppNotificationsSyncProvider.future));
          unawaited(
            syncAllBookingRemindersWithLoader(
              loadClient: () => ref.read(clientReservationsProvider.future),
              loadPresta: () => ref.read(prestataireAgendaProvider.future),
            ),
          );
          unawaited(applyPendingReferralCode(ref));
        }
      },
      loading: () async {},
      error: (_, __) async {},
    );
  }

  Future<void> _onBookingPushSideEffects(RemoteMessage msg) async {
    final type = msg.data['type'] as String?;
    final body = (msg.notification?.body ?? msg.data['body'] as String? ?? '')
        .toLowerCase();
    final isBookingStatus = type == 'booking_status' ||
        body.contains('confirmée') ||
        body.contains('confirmee');
    if (!isBookingStatus) return;

    invalidateClientReservations(ref);
    await syncClientBookingRemindersWithLoader(
      () => ref.read(clientReservationsProvider.future),
    );
    unawaited(
      syncPrestataireBookingRemindersWithLoader(
        () => ref.read(prestataireAgendaProvider.future),
      ),
    );
    ref.invalidate(inAppNotificationsSyncProvider);
    unawaited(ref.read(inAppNotificationsSyncProvider.future));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authNotifierProvider, (_, next) {
      unawaited(_apply(next));
    });
    return widget.child;
  }
}
