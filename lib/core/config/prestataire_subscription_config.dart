/// Grille d’abonnement prestataire (facturation à brancher — voir [docs/MODELE_TARIFAIRE.md]).
abstract final class PrestataireSubscriptionConfig {
  PrestataireSubscriptionConfig._();

  /// Seuil : 1 service = palier « solo », sinon palier « multi ».
  static const int multiServiceThreshold = 2;

  static const PrestataireSubscriptionTier solo = PrestataireSubscriptionTier(
    id: 'solo',
    maxServicesInclusive: 1,
    monthlyEur: 14.99,
    yearlyEur: 150,
  );

  static const PrestataireSubscriptionTier multi = PrestataireSubscriptionTier(
    id: 'multi',
    minServices: 2,
    monthlyEur: 17.99,
    yearlyEur: 180,
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
