import 'package:madbeauty/core/models/domain/reviews/review.dart';

/// Avis du client connecté, enrichi pour l'écran « Mes avis ».
class ClientReviewListItem {
  const ClientReviewListItem({
    required this.review,
    this.prestataireName,
    this.serviceName,
    this.reservationDate,
  });

  final Review review;
  final String? prestataireName;
  final String? serviceName;
  final DateTime? reservationDate;

  static const editWindow = Duration(days: 30);

  /// Modification réservée à la cliente auteure de l'avis.
  ///
  /// [ownPrestataireId] : si l'avis concerne l'activité pro de l'utilisatrice,
  /// la modification est interdite (même en espace cliente).
  bool canEditAsClient(
    String? clientProfileId, {
    String? ownPrestataireId,
  }) {
    if (clientProfileId == null || clientProfileId != review.clientId) {
      return false;
    }
    if (ownPrestataireId != null &&
        ownPrestataireId.isNotEmpty &&
        review.prestataireId == ownPrestataireId) {
      return false;
    }
    return DateTime.now().difference(review.createdAt) < editWindow;
  }

  int? daysLeftToEditFor(
    String? clientProfileId, {
    String? ownPrestataireId,
  }) {
    if (!canEditAsClient(
      clientProfileId,
      ownPrestataireId: ownPrestataireId,
    )) {
      return null;
    }
    final remaining = editWindow - DateTime.now().difference(review.createdAt);
    return remaining.inDays.clamp(0, 30);
  }
}
