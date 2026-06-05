import '../../../core/models/domain/reviews/review.dart';

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

  bool get canEdit =>
      DateTime.now().difference(review.createdAt) < editWindow;

  int? get daysLeftToEdit {
    if (!canEdit) return null;
    final remaining = editWindow - DateTime.now().difference(review.createdAt);
    return remaining.inDays.clamp(0, 30);
  }
}

