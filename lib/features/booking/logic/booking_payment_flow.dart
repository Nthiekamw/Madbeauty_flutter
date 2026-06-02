import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../../../services/stripe/stripe_booking_payment_service.dart';
import '../../../services/stripe/stripe_payment_exception.dart';
import '../../../services/stripe/stripe_service.dart';
import 'booking_pricing.dart';

enum BookingPaymentPhase {
  idle,
  preparing,
  presenting,
  confirming,
}

/// Orchestration : PaymentSheet Stripe puis création réservation.
class BookingPaymentFlow {
  const BookingPaymentFlow(this._payments);

  final StripeBookingPaymentService _payments;

  static String messageFor(StripePaymentException e) {
    return switch (e) {
      StripePaymentNotConfiguredException() => DiscPay.errNotConfigured,
      StripePaymentPrestaNotPayableException() => DiscPay.errPrestaNotPayable,
      StripePaymentSlotTakenException() => DiscPay.errSlotTaken,
      StripePaymentCanceledException() => DiscPay.errCanceled,
      StripePaymentGenericException(:final message) =>
        message == 'Erreur paiement' ? DiscPay.errGeneric : message,
    };
  }

  static bool get isPaymentAvailable =>
      !kIsWeb && StripeService.isConfigured;

  Future<Reservation> payAndCreateReservation({
    required String prestataireId,
    required String serviceId,
    required DateTime dateHeure,
    required BookingPaymentModeKind paymentMode,
    void Function(BookingPaymentPhase phase)? onPhase,
  }) async {
    onPhase?.call(BookingPaymentPhase.preparing);
    final sheet = await _payments.createPaymentIntent(
      prestataireId: prestataireId,
      serviceId: serviceId,
      dateHeure: dateHeure,
      paymentMode: paymentMode,
    );

    onPhase?.call(BookingPaymentPhase.presenting);
    await _payments.presentPaymentSheet(sheet);

    onPhase?.call(BookingPaymentPhase.confirming);
    return _payments.completeBookingAfterPayment(
      paymentIntentId: sheet.paymentIntentId,
      prestataireId: prestataireId,
      serviceId: serviceId,
      dateHeure: dateHeure,
    );
  }
}
