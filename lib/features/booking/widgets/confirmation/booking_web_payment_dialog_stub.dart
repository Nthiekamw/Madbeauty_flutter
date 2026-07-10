import 'package:flutter/material.dart';

import '../../../../services/stripe/stripe_booking_payment_service.dart';
import '../../../../services/stripe/stripe_payment_exception.dart';

/// Paiement web indisponible hors navigateur.
Future<void> showBookingWebPaymentDialog(
  BuildContext context, {
  required BookingPaymentSheetData sheet,
  required String amountLabel,
}) async {
  throw const StripePaymentGenericException();
}
