import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/logic/booking/client_reservation_ui_status.dart';
import '../../services/supabase/booking/booking_service_providers.dart';
import '../../services/supabase/likes/prestataire_like_providers.dart';
import '../../services/supabase/prestataire/prestataire_verification_service.dart';
import 'in_app_notification.dart';

/// Alimente la boîte de notifications depuis l'activité Supabase
/// (réservations), en complément des push FCM.
Future<List<InAppNotification>> fetchActivityNotifications(
  Ref ref,
) async {
  if (!AppConfig.hasSupabase) return const [];

  final out = <InAppNotification>[];
  final booking = ref.read(bookingServiceProvider);
  if (booking == null) return const [];

  final cutoff = DateTime.now().subtract(const Duration(days: 30));

  try {
    final prestaItems = await booking.listForCurrentPrestataire();
    for (final item in prestaItems) {
      if (item.dateHeure.isBefore(cutoff)) continue;
      final status = clientReservationUiStatusFromStatut(item.statut);
      final (title, type) = switch (status) {
        ClientReservationUiStatus.pending => (
            DiscNotif.bookingPendingTitle,
            'booking_pending',
          ),
        ClientReservationUiStatus.confirmed => (
            DiscNotif.bookingConfirmedTitle,
            'booking_confirmed',
          ),
        ClientReservationUiStatus.cancelled => (
            DiscNotif.bookingCancelledTitle,
            'booking_cancelled',
          ),
        ClientReservationUiStatus.done => (
            DiscNotif.bookingDoneTitle,
            'booking_done',
          ),
        _ => (null, null),
      };
      if (title == null || type == null) continue;

      out.add(
        InAppNotification(
          id: 'reservation_${item.id}_${item.statut}',
          title: title,
          body: DiscNotif.bookingBody(
            clientOrSalon: item.clientName,
            service: item.serviceName,
          ),
          createdAt: item.dateHeure,
          read: status != ClientReservationUiStatus.pending,
          actionType: type,
        ),
      );
    }
  } catch (_) {
    /* Pas prestataire ou erreur réseau */
  }

  try {
    final likeService = ref.read(prestataireLikeServiceProvider);
    if (likeService != null) {
      final prestaId = await likeService.currentPrestataireProfileId();
      if (prestaId != null) {
        final likes = await likeService.listRecentForPrestataire(
          prestaId,
          since: cutoff,
        );
        for (final like in likes) {
          out.add(
            InAppNotification(
              id:
                  'like_${like.clientId}_${like.prestataireId}_'
                  '${like.createdAt.millisecondsSinceEpoch}',
              title: DiscNotif.prestataireLikeTitle,
              body: DiscNotif.prestataireLikeBody(
                like.clientDisplayName ?? 'Une cliente',
              ),
              createdAt: like.createdAt,
              read: false,
              actionType: 'prestataire_like',
              prestataireId: like.prestataireId,
            ),
          );
        }
      }
    }
  } catch (_) {
    /* Pas prestataire ou erreur réseau */
  }

  try {
    final verificationService = PrestataireVerificationService.fromEnv();
    final events = await verificationService.listRecentDecisionEvents(
      since: cutoff,
    );
    for (final event in events) {
      final isApproved = event.action == 'approved';
      out.add(
        InAppNotification(
          id: 'verification_${event.id}',
          title: isApproved
              ? DiscNotif.verificationApprovedTitle
              : DiscNotif.verificationRevokedTitle,
          body: isApproved
              ? DiscNotif.verificationApprovedBody
              : DiscNotif.verificationRevokedBody(event.note ?? ''),
          createdAt: event.createdAt,
          read: false,
          actionType: isApproved
              ? 'prestataire_verification_approved'
              : 'prestataire_verification_revoked',
        ),
      );
    }
  } catch (_) {
    /* Pas prestataire ou erreur réseau */
  }

  try {
    final clientItems = await booking.listForCurrentClient();
    for (final item in clientItems) {
      if (item.dateHeure.isBefore(cutoff)) continue;
      final status = clientReservationUiStatusFromStatut(item.statut);
      final salon = item.prestataireName?.trim();
      if (salon == null || salon.isEmpty) continue;

      final (title, type) = switch (status) {
        ClientReservationUiStatus.pending => (
            DiscNotif.clientPendingTitle,
            'client_booking_pending',
          ),
        ClientReservationUiStatus.confirmed => (
            DiscNotif.clientConfirmedTitle,
            'client_booking_confirmed',
          ),
        ClientReservationUiStatus.cancelled => (
            DiscNotif.clientCancelledTitle,
            'client_booking_cancelled',
          ),
        ClientReservationUiStatus.done => (
            DiscNotif.clientDoneTitle,
            'client_booking_done',
          ),
        _ => (null, null),
      };
      if (title == null || type == null) continue;

      out.add(
        InAppNotification(
          id: 'reservation_${item.id}_${item.statut}',
          title: title,
          body: DiscNotif.bookingBody(
            clientOrSalon: salon,
            service: item.serviceName ?? DiscPrestaDash.unknownService,
          ),
          createdAt: item.dateHeure,
          read: status != ClientReservationUiStatus.pending &&
              status != ClientReservationUiStatus.confirmed,
          actionType: type,
          prestataireId: item.prestataireId,
          serviceId: item.serviceId,
        ),
      );
    }
  } catch (_) {
    /* Pas client ou erreur réseau */
  }

  out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  if (out.length <= 25) return out;
  return out.sublist(0, 25);
}
