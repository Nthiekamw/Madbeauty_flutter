/// Constantes du modèle tarifaire (voir [docs/MODELE_TARIFAIRE.md]).
abstract final class PricingConfig {
  PricingConfig._();

  /// Frais plateforme à partir de la 3ᵉ réservation (centimes).
  static const int platformFeeCents = 100;

  /// Acompte prestation dans l’app (pourcentage entier).
  static const int depositPercent = 20;

  /// Réservations gratuites côté frais plateforme (0 et 1 = 1ʳᵉ et 2ᵉ).
  static const int platformFeeFreeBookingCount = 2;

  /// Remise parrainage sur le prix prestation (prochaine réservation).
  static const int referralBookingDiscountPercent = 10;
}
