import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/logic/booking/client_reservation_ui_status.dart';
import '../../core/models/domain/catalog/boutique_commande.dart';
import '../../core/models/user_role.dart';
import '../../features/admin/providers/admin_bug_reports_provider.dart';
import '../../features/auth/providers/my_roles_provider.dart';
import '../../features/auth/providers/auth_notifier.dart';
import '../../services/supabase/support/user_support_providers.dart';
import '../../services/supabase/bug_report/bug_report_providers.dart';
import '../../services/supabase/booking/booking_service_providers.dart';
import '../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../features/reviews/providers/review_provider.dart';
import '../../services/supabase/likes/prestataire_like_providers.dart';
import '../../services/supabase/trust/account_moderation_service.dart';
import '../../services/supabase/prestataire/prestataire_verification_service.dart';
import 'in_app_notification.dart';
import 'in_app_notification_audience.dart';

/// Alimente la boîte de notifications depuis l'activité Supabase
/// (réservations), en complément des push FCM.
Future<List<InAppNotification>> fetchActivityNotifications(
  Ref ref,
) async {
  if (!AppConfig.hasSupabase) return const [];

  final out = <InAppNotification>[];
  final booking = ref.read(bookingServiceProvider);
  final cutoff = DateTime.now().subtract(const Duration(days: 30));

  if (booking != null) {
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
            id: 'prestataire_reservation_${item.id}',
            title: title,
            body: DiscNotif.bookingBody(
              clientOrSalon: item.clientName,
              service: item.serviceName,
            ),
            createdAt: item.dateHeure,
            read: status != ClientReservationUiStatus.pending,
            actionType: type,
            reservationId: item.id,
            audience: InAppNotificationAudience.prestataire.wire,
          ),
        );
      }
    } catch (_) {
      /* Pas prestataire ou erreur réseau */
    }
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
                  'prestataire_like_${like.clientId}_${like.prestataireId}_'
                  '${like.createdAt.millisecondsSinceEpoch}',
              title: DiscNotif.prestataireLikeTitle,
              body: DiscNotif.prestataireLikeBody(
                like.clientDisplayName ?? 'Une cliente',
              ),
              createdAt: like.createdAt,
              read: false,
              actionType: 'prestataire_like',
              prestataireId: like.prestataireId,
              audience: InAppNotificationAudience.prestataire.wire,
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
              id: 'prestataire_review_${review.id}',
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
              audience: InAppNotificationAudience.prestataire.wire,
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
          id: 'prestataire_verification_${event.id}',
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
          audience: InAppNotificationAudience.prestataire.wire,
        ),
      );
    }
  } catch (_) {
    /* Pas prestataire ou erreur réseau */
  }

  try {
    final moderationService = AccountModerationService.fromEnv();
    final events = await moderationService.listRecentForCurrentUser(
      since: cutoff,
    );
    for (final event in events) {
      final (title, type) = switch (event.eventType) {
        'photo_removed' => (
            DiscNotif.moderationPhotoRemovedTitle,
            'moderation_photo_removed',
          ),
        'photo_obscene_flagged' => (
            DiscNotif.moderationPhotoFlaggedTitle,
            'moderation_photo_flagged',
          ),
        'account_warned' => (
            DiscNotif.moderationAccountWarnedTitle,
            'moderation_account_warned',
          ),
        _ => (null, null),
      };
      if (title == null || type == null) continue;

      out.add(
        InAppNotification(
          id: 'prestataire_moderation_${event.id}',
          title: title,
          body: DiscNotif.moderationEventBody(event.message),
          createdAt: event.createdAt,
          read: false,
          actionType: type,
          audience: InAppNotificationAudience.prestataire.wire,
        ),
      );
    }
  } catch (_) {
    /* Erreur réseau modération */
  }

  try {
    final clientItems = await booking?.listForCurrentClient() ?? const [];
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
          id: 'client_reservation_${item.id}',
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
          reservationId: item.id,
          audience: InAppNotificationAudience.client.wire,
        ),
      );
    }
  } catch (_) {
    /* Pas client ou erreur réseau */
  }

  try {
    final boutiqueSvc = ref.read(boutiqueCommandeServiceProvider);
    if (boutiqueSvc != null) {
      final commandes = await boutiqueSvc.listForCurrentClient();
      for (final c in commandes) {
        if (c.createdAt.isBefore(cutoff)) continue;
        final (title, unread) = switch (c.statut) {
          BoutiqueCommandeStatut.preparing => (
              DiscNotif.boutiqueOrderPreparingTitle,
              true,
            ),
          BoutiqueCommandeStatut.ready => (
              DiscNotif.boutiqueOrderReadyTitle,
              true,
            ),
          BoutiqueCommandeStatut.completed => (
              DiscNotif.boutiqueOrderCompletedTitle,
              false,
            ),
          BoutiqueCommandeStatut.canceled => (
              DiscNotif.boutiqueOrderCanceledTitle,
              false,
            ),
          BoutiqueCommandeStatut.payOnSite ||
          BoutiqueCommandeStatut.paid => (
              DiscNotif.boutiqueOrderReceivedTitle,
              true,
            ),
          _ => (null, false),
        };
        if (title == null) continue;
        final salon = c.prestataireDisplayName?.trim().isNotEmpty == true
            ? c.prestataireDisplayName!
            : DiscBoutique.clientOrdersUnknownSalon;
        out.add(
          InAppNotification(
            id: 'client_boutique_order_${c.id}',
            title: title,
            body: DiscNotif.boutiqueOrderBody(salon),
            createdAt: c.createdAt,
            read: !unread,
            actionType: 'client_boutique_order',
            prestataireId: c.prestataireId,
            audience: InAppNotificationAudience.client.wire,
          ),
        );
      }
    }
  } catch (_) {
    /* Pas client boutique ou erreur réseau */
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
              id: 'admin_bug_report_${bug.id}',
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
              audience: InAppNotificationAudience.admin.wire,
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
            id: 'client_bug_report_status_${bug.id}_${bug.status}',
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
            audience: InAppNotificationAudience.client.wire,
          ),
        );
      }
    }
  } catch (_) {
    /* Erreur réseau */
  }

  try {
    final userId = ref.read(authNotifierProvider).value?.id;
    final threadService = ref.read(userSupportServiceProvider);
    final messageService = ref.read(userSupportMessageServiceProvider);
    if (userId != null && threadService != null && messageService != null) {
      final threadId = await threadService.ensureMyThread();
      final unread = await messageService.listUnreadFromOthers(
        threadId: threadId,
        userId: userId,
      );
      final roles = await ref.read(myRolesProvider.future);
      final supportRole =
          roles.contains(UserRole.prestataire) && !roles.contains(UserRole.client)
              ? 'prestataire'
              : 'client';
      for (final message in unread) {
        if (message.createdAt.isBefore(cutoff)) continue;
        out.add(
          InAppNotification(
            id: 'user_support_${message.id}',
            title: DiscNotif.userSupportMessageTitle,
            body: DiscNotif.userSupportMessageBody(message.content),
            createdAt: message.createdAt,
            read: false,
            actionType: 'user_support_message',
            threadId: threadId,
            role: supportRole,
            audience: supportRole,
          ),
        );
      }
    }
  } catch (_) {
    /* Pas de fil support ou erreur réseau */
  }

  out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  if (out.length <= 25) return out;
  return out.sublist(0, 25);
}
