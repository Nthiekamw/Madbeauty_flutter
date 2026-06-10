/// État d’abonnement prestataire (Stripe Billing, colonnes `prestataire_profiles`).
class PrestataireSubscriptionStatus {
  const PrestataireSubscriptionStatus({
    required this.status,
    this.tier,
    this.interval,
    this.periodEnd,
    this.stripeSubscriptionId,
    this.catalogTrialEndsAt,
  });

  final String status;
  final String? tier;
  final String? interval;
  final DateTime? periodEnd;
  final String? stripeSubscriptionId;
  final DateTime? catalogTrialEndsAt;

  static const none = 'none';

  bool get isActive => status == 'active' || status == 'trialing';

  bool get isInCatalogTrial {
    final ends = catalogTrialEndsAt;
    if (ends == null) return false;
    return ends.isAfter(DateTime.now().toUtc());
  }

  /// Abonnement Stripe actif ou essai catalogue en cours.
  bool get hasCatalogAccess => isActive || isInCatalogTrial;

  int? get catalogTrialDaysRemaining {
    if (!isInCatalogTrial) return null;
    final ends = catalogTrialEndsAt!.toUtc();
    final diff = ends.difference(DateTime.now().toUtc());
    return diff.inDays.clamp(0, 999) + (diff.inHours % 24 > 0 ? 1 : 0);
  }

  bool get needsAttention =>
      status == 'past_due' || status == 'unpaid' || status == 'incomplete';

  factory PrestataireSubscriptionStatus.fromRow(Map<String, dynamic> row) {
    final periodRaw = row['subscription_current_period_end'];
    DateTime? periodEnd;
    if (periodRaw is String && periodRaw.isNotEmpty) {
      periodEnd = DateTime.tryParse(periodRaw);
    }

    final trialRaw = row['catalog_trial_ends_at'];
    DateTime? catalogTrialEndsAt;
    if (trialRaw is String && trialRaw.isNotEmpty) {
      catalogTrialEndsAt = DateTime.tryParse(trialRaw);
    }

    return PrestataireSubscriptionStatus(
      status: row['subscription_status'] as String? ?? none,
      tier: row['subscription_tier'] as String?,
      interval: row['subscription_interval'] as String?,
      periodEnd: periodEnd,
      stripeSubscriptionId: row['stripe_subscription_id'] as String?,
      catalogTrialEndsAt: catalogTrialEndsAt,
    );
  }

  factory PrestataireSubscriptionStatus.empty() =>
      const PrestataireSubscriptionStatus(status: none);
}
