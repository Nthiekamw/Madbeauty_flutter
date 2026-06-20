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

class _LiveUpdatesCoordinatorState extends ConsumerState<LiveUpdatesCoordinator> {
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _clientReservationsChannel;
  RealtimeChannel? _prestaReservationsChannel;
  RealtimeChannel? _userSupportChannel;
  String? _subscribedUserId;
  String? _subscribedSupportThreadId;

  @override
  void dispose() {
    unawaited(_teardown());
    super.dispose();
  }

  Future<void> _teardown() async {
    _subscribedUserId = null;
    for (final channel in [
      _messagesChannel,
      _clientReservationsChannel,
      _prestaReservationsChannel,
      _userSupportChannel,
    ]) {
      if (channel != null) {
        await SupabaseService.client.removeChannel(channel);
      }
    }
    _messagesChannel = null;
    _clientReservationsChannel = null;
    _prestaReservationsChannel = null;
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
    if (_subscribedUserId == user.id &&
        _messagesChannel != null &&
        _userSupportChannel != null) {
      return;
    }

    await _teardown();
    _subscribedUserId = user.id;

    final client = await ref.read(currentClientProfileProvider.future);
    final presta = await ref.read(currentPrestataireProvider.future);

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
    }

    try {
      final supportService = ref.read(userSupportServiceProvider);
      if (supportService != null) {
        _subscribedSupportThreadId = await supportService.ensureMyThread();
        final threadId = _subscribedSupportThreadId!;
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
    final bookingId = payload.newRecord['booking_id'] as String?;
    refreshMessagingLiveState(ref, bookingId: bookingId);
  }

  void _onReservationsChange() {
    if (!mounted) return;
    refreshReservationsLiveState(ref);
  }

  @override
  Widget build(BuildContext context) {
    if (AppConfig.hasSupabase) {
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
