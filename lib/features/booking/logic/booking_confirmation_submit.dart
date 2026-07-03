import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/notifications/booking_reminders_sync.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/offline/offline_queue_helper.dart';
import '../../../services/offline/pending_offline_action.dart';
import '../../../services/supabase/booking/booking_service_providers.dart'
    show
        bookingServiceProvider,
        invalidateBookingDetail,
        invalidateClientReservations;
import '../../../services/supabase/referral/referral_providers.dart';
import '../../prestataire/providers/catalog/prestataire_detail_provider.dart';
import '../logic/booking_create_failure.dart';
import '../logic/booking_pricing.dart';
import '../providers/booking_platform_fee_settings_provider.dart';
import '../providers/client_prior_booking_count_provider.dart';

/// Résultat d'une confirmation de réservation réussie.
class BookingConfirmSuccess {
  const BookingConfirmSuccess({
    required this.queuedOffline,
    required this.paidOnSite,
  });

  final bool queuedOffline;
  final bool paidOnSite;
}

/// Logique de confirmation (paiement sur place, file offline).
abstract final class BookingConfirmationSubmit {
  BookingConfirmationSubmit._();

  static Future<BookingConfirmSuccess?> confirm({
    required WidgetRef ref,
    required BuildContext context,
    required String prestataireId,
    required String serviceId,
    required String serviceName,
    required double price,
    required DateTime dateTime,
    required void Function(String message) onError,
  }) async {
    final bookingService = ref.read(bookingServiceProvider);

    final priorCount = await ref.read(clientPriorBookingCountProvider.future);
    final referralDiscountPercent =
        ref.read(clientReferralDiscountPercentProvider);
    const effectiveMode = BookingPaymentModeKind.onSite;

    final platformFeeSettings = await ref.read(
      bookingPlatformFeeSettingsProvider.future,
    );

    BookingPricingBreakdown breakdown;
    try {
      breakdown = computeBookingPricing(
        servicePriceEur: price,
        paymentMode: effectiveMode,
        priorBookingCount: priorCount,
        prestataireAcceptsConnect: false,
        platformFeeSettings: platformFeeSettings,
        referralDiscountPercent: referralDiscountPercent,
      );
    } on BookingPricingException {
      onError(DiscBk.errGenericSave);
      return null;
    }

    if (!AppConfig.hasSupabase) {
      onError(
        'Configuration Supabase absente. Relance avec '
        'flutter run --dart-define-from-file=.env',
      );
      return null;
    }
    if (bookingService == null) {
      onError(DiscBk.errGenericSave);
      return null;
    }

    final detail = ref.read(prestataireDetailProvider(prestataireId)).value;
    final profile = detail?.profile;
    final salon = profile?.nomSalon?.trim();
    final prestataireName =
        salon != null && salon.isNotEmpty ? salon : 'Salon';

    final localId = PendingOfflineAction.newLocalReservationId();
    final queued = await enqueueIfOffline(
      ref: ref,
      context: context,
      action: PendingOfflineAction.create(
        type: OfflineActionType.bookingCreate,
        payload: {
          'localReservationId': localId,
          'prestataireId': prestataireId,
          'serviceId': serviceId,
          'dateHeure': dateTime.toIso8601String(),
          'serviceName': serviceName,
          'prestataireName': prestataireName,
          'prestataireAvatarUrl': detail?.avatarUrl,
        },
      ),
    );

    if (queued) {
      return const BookingConfirmSuccess(
        queuedOffline: true,
        paidOnSite: false,
      );
    }

    try {
      final reservation = await bookingService.create(
        prestataireId: prestataireId,
        serviceId: serviceId,
        dateHeure: dateTime,
        paymentMode: effectiveMode.wireValue,
        servicePriceCents: breakdown.servicePriceCents,
        platformFeeCents: breakdown.platformFeeCents,
        originalServicePriceCents: breakdown.hasReferralDiscount
            ? breakdown.originalServicePriceCents
            : null,
        referralDiscountPercent: breakdown.referralDiscountPercent,
      );
      _afterBookingCreated(
        ref: ref,
        reservationId: reservation.id,
        dateHeure: reservation.dateHeure,
        serviceName: serviceName,
        statut: reservation.statut,
      );
      return const BookingConfirmSuccess(
        queuedOffline: false,
        paidOnSite: true,
      );
    } on FormatException catch (e) {
      onError(e.message.isNotEmpty ? e.message : DiscBk.errGenericSave);
    } catch (error, stackTrace) {
      debugPrint('Booking confirm failed: $error\n$stackTrace');
      onError(bookingCreateFailureMessage(error));
    }
    return null;
  }

  static void _afterBookingCreated({
    required WidgetRef ref,
    required String reservationId,
    required DateTime dateHeure,
    required String serviceName,
    required String statut,
  }) {
    invalidateBookingDetail(ref, reservationId);
    invalidateClientReservations(ref);
    ref.invalidate(clientPriorBookingCountProvider);
    ref.invalidate(myReferralInfoProvider);
    ref.invalidate(inAppNotificationsSyncProvider);
    unawaited(
      syncClientBookingRemindersForOne(
        id: reservationId,
        dateHeure: dateHeure,
        serviceName: serviceName,
        statut: statut,
      ),
    );
  }
}
