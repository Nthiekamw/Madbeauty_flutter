import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/logic/booking/client_reservation_ui_status.dart';
import '../../../core/providers/offline_providers.dart';
import '../../../features/prestataire/providers/profile/current_prestataire_provider.dart';
import '../../../features/prestataire/providers/booking/prestataire_bookings_invalidate.dart';
import '../../../services/notifications/booking_push_notifications.dart';
import '../../../services/notifications/in_app_notification.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/supabase/booking/booking_service_core_providers.dart';
import '../../../services/supabase/supabase_service.dart';

/// Alertes temps réel pour le prestataire (nouvelle réservation via Realtime).
class PrestataireBookingNotificationCoordinator extends ConsumerStatefulWidget {
  const PrestataireBookingNotificationCoordinator({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<PrestataireBookingNotificationCoordinator> createState() =>
      _PrestataireBookingNotificationCoordinatorState();
}

class _PrestataireBookingNotificationCoordinatorState
    extends ConsumerState<PrestataireBookingNotificationCoordinator> {
  RealtimeChannel? _channel;
  String? _subscribedPrestataireId;

  @override
  void dispose() {
    unawaited(_unsubscribe());
    super.dispose();
  }

  Future<void> _unsubscribe() async {
    final ch = _channel;
    _channel = null;
    _subscribedPrestataireId = null;
    if (ch != null && AppConfig.hasSupabase) {
      await SupabaseService.client.removeChannel(ch);
    }
  }

  Future<void> _subscribe(String prestataireId) async {
    if (!AppConfig.hasSupabase || !ref.read(isOnlineProvider)) return;
    if (_subscribedPrestataireId == prestataireId) return;

    await _unsubscribe();
    _subscribedPrestataireId = prestataireId;

    _channel = SupabaseService.client
        .channel('prestataire-booking-notify-$prestataireId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'reservations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'prestataire_id',
            value: prestataireId,
          ),
          callback: (payload) {
            unawaited(_onReservationInserted(payload.newRecord));
          },
        )
        .subscribe();
  }

  Future<void> _onReservationInserted(Map<String, dynamic> record) async {
    if (!mounted) return;

    final statut = record['statut']?.toString() ?? '';
    if (clientReservationUiStatusFromStatut(statut) !=
        ClientReservationUiStatus.pending) {
      return;
    }

    final reservationId = record['id']?.toString();
    if (reservationId == null || reservationId.isEmpty) return;

    invalidatePrestataireBookings(ref);
    ref.invalidate(inAppNotificationsSyncProvider);

    final booking = ref.read(bookingServiceProvider);
    if (booking == null) return;

    try {
      final items = await booking.listForCurrentPrestataire();
      final item = items.where((e) => e.id == reservationId).firstOrNull;
      if (item == null || !mounted) return;

      final body = DiscNotif.bookingBody(
        clientOrSalon: item.clientName,
        service: item.serviceName,
      );

      ref.read(inAppNotificationsProvider.notifier).enqueue(
            InAppNotification(
              id: 'reservation_${item.id}_${item.statut}',
              title: DiscNotif.bookingPendingTitle,
              body: body,
              createdAt: DateTime.now(),
              read: false,
              actionType: 'booking_pending',
            ),
          );

      await BookingPushNotifications.instance.showLocalAlert(
        title: DiscNotif.bookingPendingTitle,
        body: body,
      );
    } catch (_) {
      /* Réseau ou profil — la sync inbox rattrapera */
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppConfig.hasSupabase) {
      ref.listen(isOnlineProvider, (prev, online) {
        final prestaId = _subscribedPrestataireId;
        if (online && prestaId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(_subscribe(prestaId));
          });
        } else if (!online) {
          unawaited(_unsubscribe());
        }
      });

      ref.listen(currentPrestataireProvider, (prev, next) {
        next.whenData((presta) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (presta == null) {
              unawaited(_unsubscribe());
              return;
            }
            unawaited(_subscribe(presta.id));
          });
        });
      });
    }

    return widget.child;
  }
}
