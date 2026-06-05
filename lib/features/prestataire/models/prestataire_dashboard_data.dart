import 'prestataire_reservation_item.dart';

/// Données du tableau de bord prestataire (demandes + journée).
class PrestataireDashboardData {
  const PrestataireDashboardData({
    required this.pending,
    required this.todayConfirmed,
    required this.weekConfirmed,
  });

  final List<PrestataireReservationItem> pending;
  final List<PrestataireReservationItem> todayConfirmed;

  /// Confirmées sur les 7 prochains jours (hors liste « aujourd'hui » déjà affichée).
  final List<PrestataireReservationItem> weekConfirmed;
}

