import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../services/offline/offline_queue_helper.dart';
import '../../../services/offline/pending_offline_action.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../providers/prestataire_bookings_invalidate.dart';
import '../widgets/reject_reservation_dialog.dart';

/// Actions réservation (accepter, refuser, terminer) partagées dashboard / agenda.
class PrestataireReservationActions {
  PrestataireReservationActions(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  Future<bool> accept(String reservationId) async {
    final booking = ref.read(bookingServiceProvider);
    if (booking == null) {
      _snack(DiscPrestaDash.actionErr);
      return false;
    }
    if (await enqueueIfOffline(
      ref: ref,
      context: context,
      action: PendingOfflineAction.create(
        type: OfflineActionType.bookingConfirm,
        payload: {'reservationId': reservationId},
      ),
    )) {
      invalidatePrestataireBookings(ref);
      return true;
    }

    try {
      await booking.confirm(reservationId);
      invalidatePrestataireBookings(ref);
      _snack(DiscPrestaDash.actionOk);
      return true;
    } on AppFailure catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(DiscPrestaDash.actionErr);
    }
    return false;
  }

  Future<bool> reject(String reservationId) async {
    final reason = await showRejectReservationDialog(context);
    if (!context.mounted) return false;
    if (reason == null) return false;

    final booking = ref.read(bookingServiceProvider);
    if (booking == null) {
      _snack(DiscPrestaDash.actionErr);
      return false;
    }
    if (await enqueueIfOffline(
      ref: ref,
      context: context,
      action: PendingOfflineAction.create(
        type: OfflineActionType.bookingReject,
        payload: {
          'reservationId': reservationId,
          if (reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
      ),
    )) {
      invalidatePrestataireBookings(ref);
      return true;
    }

    try {
      await booking.rejectByPrestataire(reservationId, reason: reason);
      invalidatePrestataireBookings(ref);
      _snack(DiscPrestaDash.actionOk);
      return true;
    } on AppFailure catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(DiscPrestaDash.actionErr);
    }
    return false;
  }

  Future<bool> markDone(String reservationId) async {
    final booking = ref.read(bookingServiceProvider);
    if (booking == null) {
      _snack(DiscPrestaDash.actionErr);
      return false;
    }
    if (await enqueueIfOffline(
      ref: ref,
      context: context,
      action: PendingOfflineAction.create(
        type: OfflineActionType.bookingMarkDone,
        payload: {'reservationId': reservationId},
      ),
    )) {
      invalidatePrestataireBookings(ref);
      return true;
    }

    try {
      await booking.markAsDone(reservationId);
      invalidatePrestataireBookings(ref);
      _snack(DiscPrestaDash.actionOk);
      return true;
    } on AppFailure catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(DiscPrestaDash.actionErr);
    }
    return false;
  }

  void _snack(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
