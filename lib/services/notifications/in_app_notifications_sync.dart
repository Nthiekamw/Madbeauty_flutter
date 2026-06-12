import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/logic/booking/client_reservation_ui_status.dart';
import '../../core/models/user_role.dart';
import '../../features/admin/providers/admin_bug_reports_provider.dart';
import '../../features/auth/providers/my_roles_provider.dart';
import '../../services/supabase/bug_report/bug_report_providers.dart';
import '../../services/supabase/booking/booking_service_providers.dart';
import '../../features/reviews/providers/review_provider.dart';
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
    final reviewService = ref.read(reviewServiceProvider);
    final likeService = ref.read(prestataireLikeServiceProvider);
    if (reviewService != null && likeService != null) {
      final prestaId = await likeService.currentPrestataireProfileId();
      if (prestaId != null) {
        final reviews = await reviewService.listRecentForPrestataire(
          prestaId,
          since: cutoff,
        );
        for (final review in reviews) {
          out.add(
            InAppNotification(
              id: 'review_${review.id}',
              title: DiscNotif.prestataireReviewTitle(review.note),
              body: DiscNotif.prestataireReviewBody(
                clientName: review.clientDisplayName ?? 'Une cliente',
                note: review.note,
                comment: review.commentaire,
              ),
              createdAt: review.createdAt,
              read: false,
              actionType: 'prestataire_review',
              prestataireId: review.prestataireId,
              reservationId: review.reservationId,
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

  try {
    final roles = await ref.read(myRolesProvider.future);
    if (roles.contains(UserRole.admin)) {
      final adminService = ref.read(adminBugReportsServiceProvider);
      if (adminService != null) {
        final pending = await adminService.listReports(
          onlyPending: true,
          limit: 15,
        );
        for (final bug in pending) {
          out.add(
            InAppNotification(
              id: 'bug_report_admin_${bug.id}',
              title: DiscNotif.bugReportNewTitle,
              body: DiscNotif.bugReportNewBody(
                category: DiscBug.categoryLabel(bug.category),
                title: bug.title,
              ),
              createdAt: bug.createdAt,
              read: false,
              actionType: 'bug_report',
              nav: 'admin_bug_reports',
              bugReportId: bug.id,
            ),
          );
        }
      }
    }
  } catch (_) {
    /* Pas admin ou erreur réseau */
  }

  try {
    final bugService = ref.read(bugReportServiceProvider);
    if (bugService != null) {
      final mine = await bugService.listMine(limit: 20);
      for (final bug in mine) {
        if (!bug.isTerminal || bug.updatedAt.isBefore(cutoff)) continue;
        out.add(
          InAppNotification(
            id: 'bug_report_status_${bug.id}_${bug.status}',
            title: DiscNotif.bugReportStatusTitle,
            body: DiscNotif.bugReportStatusBody(
              title: bug.title,
              statusLabel: DiscBug.statusLabel(bug.status).toLowerCase(),
              reporterMessage: bug.reporterMessage,
            ),
            createdAt: bug.updatedAt,
            read: false,
            actionType: 'bug_report_status',
            nav: 'my_bug_reports',
            bugReportId: bug.id,
          ),
        );
      }
    }
  } catch (_) {
    /* Erreur réseau */
  }

  out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  if (out.length <= 25) return out;
  return out.sublist(0, 25);
}
