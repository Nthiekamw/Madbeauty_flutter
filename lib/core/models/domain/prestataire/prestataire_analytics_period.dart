/// Filtre de période du tableau de bord analytique.
enum PrestataireAnalyticsPeriod {
  days7(7, '7 jours'),
  days30(30, '30 jours'),
  months3(90, '3 mois');

  const PrestataireAnalyticsPeriod(this.days, this.label);

  final int days;
  final String label;
}
