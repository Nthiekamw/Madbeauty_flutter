import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/providers/offline_providers.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/notifications/in_app_notification.dart';
import '../../../services/notifications/in_app_notification_audience.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/notifications/live_refresh.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/supabase_service.dart';
import '../../../services/supabase/support/user_support_providers.dart';
import '../../prestataire/providers/profile/current_prestataire_provider.dart';

/// Realtime Supabase : badges messages / réservations + fil chat sans pull-to-refresh.
class LiveUpdatesCoordinator extends ConsumerStatefulWidget {
  const LiveUpdatesCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LiveUpdatesCoordinator> createState() =>
      _LiveUpdatesCoordinatorState();
}

class _LiveUpdatesCoordinatorState extends ConsumerState<LiveUpdatesCoordinator>
    with WidgetsBindingObserver {
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _clientReservationsChannel;
  RealtimeChannel? _prestaReservationsChannel;
  RealtimeChannel? _prestaLikesChannel;
  RealtimeChannel? _prestaReviewsChannel;
  RealtimeChannel? _userSupportChannel;
  String? _subscribedUserId;
  String? _subscribedClientId;
  String? _subscribedPrestaId;
  String? _subscribedSupportThreadId;
  Timer? _foregroundSyncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || !AppConfig.hasSupabase) return;
    switch (state) {
      case AppLifecycleState.resumed:
        refreshInAppNotificationsSync(ref);
        refreshMessagingInbox(ref);
        _startForegroundSyncTimer();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(_resubscribe());
        });
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _foregroundSyncTimer?.cancel();
        _foregroundSyncTimer = null;
    }
  }

  void _startForegroundSyncTimer() {
    _foregroundSyncTimer?.cancel();
    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null || !ref.read(isOnlineProvider)) return;

    _foregroundSyncTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      if (!mounted) return;
      refreshInAppNotificationsSync(ref);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _foregroundSyncTimer?.cancel();
    unawaited(_teardown());
    super.dispose();
  }

  Future<void> _teardown() async {
    _subscribedUserId = null;
    _subscribedClientId = null;
    _subscribedPrestaId = null;
    for (final channel in [
      _messagesChannel,
      _clientReservationsChannel,
      _prestaReservationsChannel,
      _prestaLikesChannel,
      _prestaReviewsChannel,
      _userSupportChannel,
    ]) {
      if (channel != null) {
        await SupabaseService.client.removeChannel(channel);
      }
    }
    _messagesChannel = null;
    _clientReservationsChannel = null;
    _prestaReservationsChannel = null;
    _prestaLikesChannel = null;
    _prestaReviewsChannel = null;
    _userSupportChannel = null;
    _subscribedSupportThreadId = null;
  }

  Future<void> _resubscribe() async {
    if (!AppConfig.hasSupabase || !mounted) return;
    if (!ref.read(isOnlineProvider)) {
      await _teardown();
      return;
    }

    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) {
      await _teardown();
      return;
    }

    final client = await ref.read(currentClientProfileProvider.future);
    final presta = await ref.read(currentPrestataireProvider.future);

    if (_subscribedUserId == user.id &&
        _subscribedClientId == client?.id &&
        _subscribedPrestaId == presta?.id &&
        _messagesChannel != null) {
      return;
    }

    await _teardown();
    _subscribedUserId = user.id;
    _subscribedClientId = client?.id;
    _subscribedPrestaId = presta?.id;

    _messagesChannel = SupabaseService.client
        .channel('live-messages-${user.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: _onMessagesChange,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: _onMessagesChange,
        )
        .subscribe();

    if (client != null) {
      _clientReservationsChannel = SupabaseService.client
          .channel('live-res-client-${client.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'reservations',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'client_id',
              value: client.id,
            ),
            callback: (_) => _onReservationsChange(),
          )
          .subscribe();
    }

    if (presta != null) {
      _prestaReservationsChannel = SupabaseService.client
          .channel('live-res-presta-${presta.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'reservations',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'prestataire_id',
              value: presta.id,
            ),
            callback: (_) => _onReservationsChange(),
          )
          .subscribe();

      _prestaLikesChannel = SupabaseService.client
          .channel('live-presta-likes-${presta.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'prestataire_likes',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'prestataire_id',
              value: presta.id,
            ),
            callback: _onPrestaLike,
          )
          .subscribe();

      _prestaReviewsChannel = SupabaseService.client
          .channel('live-presta-reviews-${presta.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'avis',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'prestataire_id',
              value: presta.id,
            ),
            callback: (_) => _onPrestaActivityChange(),
          )
          .subscribe();
    }

    try {
      final supportService = ref.read(userSupportServiceProvider);
      if (supportService != null) {
        final threadId = await supportService.ensureMyThread();
        _subscribedSupportThreadId = threadId;
        _userSupportChannel = SupabaseService.client
            .channel('live-user-support-${user.id}')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'user_support_messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'thread_id',
                value: threadId,
              ),
              callback: (payload) => _onUserSupportMessage(user.id, payload),
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'user_support_messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'thread_id',
                value: threadId,
              ),
              callback: (_) => refreshUserSupportLiveState(ref),
            )
            .subscribe();
      }
    } catch (_) {
      _subscribedSupportThreadId = null;
    }

    refreshInAppNotificationsSync(ref);
    _startForegroundSyncTimer();
  }

  void _onPrestaLike(PostgresChangePayload payload) {
    if (!mounted) return;

    final clientName =
        payload.newRecord['client_display_name'] as String? ?? 'Une cliente';
    final clientId = payload.newRecord['client_id'] as String? ?? '';
    final prestaId = payload.newRecord['prestataire_id'] as String? ?? '';
    final createdAtRaw = payload.newRecord['created_at'] as String?;
    final createdAt = createdAtRaw == null
        ? DateTime.now()
        : DateTime.tryParse(createdAtRaw) ?? DateTime.now();

    ref.read(inAppNotificationsProvider.notifier).enqueue(
          InAppNotification(
            id: 'prestataire_like_${clientId}_${prestaId}_'
                '${createdAt.millisecondsSinceEpoch}',
            title: DiscNotif.prestataireLikeTitle,
            body: DiscNotif.prestataireLikeBody(clientName),
            createdAt: createdAt,
            read: false,
            actionType: 'prestataire_like',
            prestataireId: prestaId.isEmpty ? null : prestaId,
            audience: InAppNotificationAudience.prestataire.wire,
          ),
        );
    refreshInAppNotificationsSync(ref);
  }

  void _onPrestaActivityChange() {
    if (!mounted) return;
    refreshInAppNotificationsSync(ref);
  }

  void _onUserSupportMessage(String userId, PostgresChangePayload payload) {
    if (!mounted) return;
    final senderId = payload.newRecord['sender_id'] as String?;
    if (senderId == null || senderId == userId) return;

    final content = payload.newRecord['content'] as String? ?? '';
    final messageId = payload.newRecord['id'] as String? ?? '';
    final threadId = payload.newRecord['thread_id'] as String?;

    ref.read(inAppNotificationsProvider.notifier).enqueue(
          InAppNotification(
            id: messageId.isEmpty
                ? 'user_support_${DateTime.now().microsecondsSinceEpoch}'
                : 'user_support_$messageId',
            title: DiscNotif.userSupportMessageTitle,
            body: DiscNotif.userSupportMessageBody(content),
            createdAt: DateTime.now(),
            read: false,
            actionType: 'user_support_message',
            threadId: threadId,
            role: InAppNotificationAudience.client.wire,
            audience: InAppNotificationAudience.client.wire,
          ),
        );
    refreshUserSupportLiveState(ref);
  }

  void _onMessagesChange(PostgresChangePayload payload) {
    if (!mounted) return;
    final conversationId = payload.newRecord['conversation_id'] as String?;
    final bookingId = payload.newRecord['booking_id'] as String?;
    refreshMessagingLiveState(
      ref,
      conversationId: conversationId,
      bookingId: bookingId,
    );
  }

  void _onReservationsChange() {
    if (!mounted) return;
    refreshReservationsLiveState(ref);
  }

  @override
  Widget build(BuildContext context) {
    if (AppConfig.hasSupabase) {
      final user = switch (ref.watch(authNotifierProvider)) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user != null) {
        ref.watch(inAppNotificationsSyncProvider);
      }

      ref.listen(isOnlineProvider, (prev, online) {
        if (online && prev == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(_resubscribe());
          });
        } else if (!online) {
          unawaited(_teardown());
        }
      });

      ref.listen(authNotifierProvider, (_, next) {
        next.whenData((user) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (user == null) {
              unawaited(_teardown());
            } else {
              unawaited(_resubscribe());
            }
          });
        });
      });

      ref.listen(currentClientProfileProvider, (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_resubscribe());
        });
      });

      ref.listen(currentPrestataireProvider, (_, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_resubscribe());
        });
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_resubscribe());
      });
    }

    return widget.child;
  }
}
