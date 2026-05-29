/// Erreurs métier paiement réservation.
sealed class StripePaymentException implements Exception {
  const StripePaymentException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

final class StripePaymentNotConfiguredException extends StripePaymentException {
  const StripePaymentNotConfiguredException()
      : super('Stripe non configuré', code: 'not_configured');
}

final class StripePaymentPrestaNotPayableException extends StripePaymentException {
  const StripePaymentPrestaNotPayableException()
      : super('Prestataire non payable', code: 'prestataire_not_payable');
}

final class StripePaymentSlotTakenException extends StripePaymentException {
  const StripePaymentSlotTakenException()
      : super('Créneau indisponible', code: 'slot_taken');
}

final class StripePaymentCanceledException extends StripePaymentException {
  const StripePaymentCanceledException()
      : super('Paiement annulé', code: 'canceled');
}

final class StripePaymentGenericException extends StripePaymentException {
  const StripePaymentGenericException([String? detail])
      : super(detail ?? 'Erreur paiement', code: 'generic');
}
