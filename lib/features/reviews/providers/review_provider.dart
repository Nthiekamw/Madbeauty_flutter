import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/domain/reviews/review.dart';
import '../../../services/supabase/reviews/review_service.dart';
import '../../../services/supabase/supabase_service.dart';

final reviewServiceProvider = Provider<ReviewService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ReviewService(SupabaseService.client);
});

/// Avis publics d'un prestataire.
final reviewsByPrestataireProvider = FutureProvider.autoDispose
    .family<List<Review>, String>((ref, prestataireId) async {
  final service = ref.watch(reviewServiceProvider);
  if (service == null) return [];
  return service.getByPrestataire(prestataireId);
});

/// Indique si le client a déjà noté cette réservation ([bookingId]).
final hasReviewedProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, bookingId) async {
  final service = ref.watch(reviewServiceProvider);
  if (service == null) return false;
  return service.hasReviewed(bookingId);
});
