/// Libellés d’essai catalogue (jours / mois).
abstract final class TrialDurationFormat {
  TrialDurationFormat._();

  /// Ex. « 3 mois », « 14 jours ».
  static String labelShort(int days) {
    if (days >= 30 && days % 30 == 0) {
      final months = days ~/ 30;
      return months == 1 ? '1 mois' : '$months mois';
    }
    return '$days jour${days > 1 ? 's' : ''}';
  }

  static String trialBadge(int days) => 'Essai ${labelShort(days)}';

  static String onboardingBody(int days) =>
      'Tu bénéficies de ${labelShort(days)} d’essai gratuit pour apparaître dans le catalogue. '
      'Complète ton profil pour inspirer confiance et recevoir des réservations.';

  static String checkoutTrialHint(int days) =>
      '${labelShort(days)} d’essai catalogue offerts — aucun paiement dans l’app.';
}
