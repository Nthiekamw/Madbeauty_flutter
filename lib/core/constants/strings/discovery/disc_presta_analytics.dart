/// Tableau de bord analytique prestataire.
abstract final class DiscPrestaAnalytics {
  DiscPrestaAnalytics._();

  static const sectionTitle = 'Performance';
  static const filterPeriod = 'Période';
  static const revenueTitle = 'Revenus';
  static const revenuePeriod = 'Chiffre d’affaires';
  static const revenueVsPrev = 'vs période précédente';
  static const revenueChart = 'Évolution';
  static const occupancyTitle = 'Taux d’occupation';
  static const occupancyHint =
      'Part des créneaux ouverts déjà réservés sur la période.';
  static const occupancyHeatmap = 'Jours les plus chargés';
  static const reservationsTitle = 'Réservations';
  static const totalRequests = 'Demandes';
  static const cancelled = 'Annulées';
  static const confirmed = 'Confirmées';
  static const completed = 'Terminées';
  static const conversion = 'Taux de conversion';
  static const conversionHint = 'Confirmées ÷ (demandes − annulées)';
  static const loadErr = 'Impossible de charger les statistiques.';
  static const noData = '—';
  static const revenueBreakdown =
      'Stripe capturé + paiements sur place (prestations confirmées ou terminées).';

  static String evolutionPercent(double? percent) {
    if (percent == null) return noData;
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(0)} %';
  }

  static String percentValue(double? percent) {
    if (percent == null) return noData;
    return '${percent.toStringAsFixed(0)} %';
  }

  static String busiestDay(String? weekdayName) {
    if (weekdayName == null || weekdayName.isEmpty) {
      return 'Pas assez de données';
    }
    return 'Pic : $weekdayName';
  }
}
