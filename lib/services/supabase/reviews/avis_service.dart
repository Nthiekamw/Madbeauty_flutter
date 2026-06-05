import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/domain/reviews/avis.dart';
import 'review_service.dart';

/// @deprecated Préférer [ReviewService] et [reviewsByPrestataireProvider].
class AvisService {
  AvisService(SupabaseClient client) : _reviews = ReviewService(client);

  final ReviewService _reviews;

  Future<List<Avis>> getByPrestataireId(String prestataireId) async {
    final list = await _reviews.getByPrestataire(prestataireId);
    return [
      for (final r in list)
        Avis(
          id: r.id,
          clientId: r.clientId,
          prestataireId: r.prestataireId,
          reservationId: r.bookingId,
          note: r.note,
          commentaire: r.commentaire,
          createdAt: r.createdAt,
        ),
    ];
  }
}

