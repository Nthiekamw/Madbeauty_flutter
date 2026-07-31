/// Constantes du programme de fidélité MadBeauty.
abstract final class LoyaltyConfig {
  LoyaltyConfig._();

  /// Points gagnés par réservation avec acompte app, une fois terminée.
  static const int pointsPerEligibleBooking = 2;

  /// Seuil pour une prestation offerte.
  static const int pointsPerReward = 200;

  /// Plafond de la prestation offerte (centimes) — 50 €.
  static const int maxRewardCents = 5000;

  /// Mode de paiement éligible au gain de points.
  static const String eligiblePaymentMode = 'deposit_20';

  /// Badges (seuils en points lifetime gagnés).
  static const List<int> badgeThresholds = [50, 100, 150, 200];
}
