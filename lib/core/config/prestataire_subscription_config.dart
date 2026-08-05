/// Grille d’abonnement prestataire (voir [docs/product/PRICING.md]).
abstract final class PrestataireSubscriptionConfig {
  PrestataireSubscriptionConfig._();

  /// Essai catalogue + Stripe (premier abonnement) — défaut plateforme 3 mois.
  static const int catalogTrialDays = 90;

  /// Seuil : 1 service = palier « solo », sinon palier « multi ».
  static const int multiServiceThreshold = 2;

  static const PrestataireSubscriptionTier solo = PrestataireSubscriptionTier(
    id: 'solo',
    maxServicesInclusive: 1,
    monthlyEur: 18,
    yearlyEur: 180,
  );

  static const PrestataireSubscriptionTier multi = PrestataireSubscriptionTier(
    id: 'multi',
    minServices: 2,
    monthlyEur: 24.99,
    yearlyEur: 250,
  );

  static PrestataireSubscriptionTier tierForServiceCount(int serviceCount) {
    if (serviceCount < multiServiceThreshold) return solo;
    return multi;
  }
}

class PrestataireSubscriptionTier {
  const PrestataireSubscriptionTier({
    required this.id,
    this.maxServicesInclusive,
    this.minServices,
    required this.monthlyEur,
    required this.yearlyEur,
  });

  final String id;
  final int? maxServicesInclusive;
  final int? minServices;
  final double monthlyEur;
  final double yearlyEur;
}
