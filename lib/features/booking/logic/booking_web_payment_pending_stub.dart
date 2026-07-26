/// Données conservées pendant une redirection 3DS Stripe (web).
class BookingWebPaymentPendingData {
  const BookingWebPaymentPendingData({
    required this.paymentIntentId,
    required this.prestataireId,
    required this.dateHeureIso,
    this.serviceId,
    this.packId,
  });

  final String paymentIntentId;
  final String prestataireId;
  final String? serviceId;
  final String? packId;
  final String dateHeureIso;
}

/// Persistance sessionStorage du paiement en cours (no-op hors web).
abstract final class BookingWebPaymentPending {
  BookingWebPaymentPending._();

  static void save(BookingWebPaymentPendingData data) {}

  static BookingWebPaymentPendingData? read() => null;

  static void clear() {}
}
