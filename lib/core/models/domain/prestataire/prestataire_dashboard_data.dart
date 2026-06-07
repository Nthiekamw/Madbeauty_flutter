import 'package:madbeauty/core/models/domain/booking/prestataire_reservation_item.dart';

/// Données du tableau de bord prestataire (demandes + journée).
class PrestataireDashboardData {
  const PrestataireDashboardData({
    required this.pending,
    required this.todayConfirmed,
    required this.weekConfirmed,
    this.needsCompletion = const [],
  });

  final List<PrestataireReservationItem> pending;
  final List<PrestataireReservationItem> todayConfirmed;

  /// Confirmées sur les 7 prochains jours (hors liste « aujourd'hui » déjà affichée).
  final List<PrestataireReservationItem> weekConfirmed;

  /// Confirmées dont le créneau est passé — à marquer terminées.
  final List<PrestataireReservationItem> needsCompletion;
}
