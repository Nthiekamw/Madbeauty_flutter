/// VIP salon : ≥ N RDV terminés chez le même prestataire → badge + remise.
abstract final class SalonVipConfig {
  SalonVipConfig._();

  /// Nombre de réservations terminées pour devenir VIP chez ce salon.
  static const int minCompletedBookings = 3;

  /// Remise checkout (%) pour une cliente VIP chez ce presta.
  static const int discountPercent = 5;
}
