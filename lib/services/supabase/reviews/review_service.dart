import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/reviews/review.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
/// Avis clients (table `avis`) liés aux réservations terminées.
class ReviewService {
  ReviewService(this._client);

  final SupabaseClient _client;

  static const _completedStatuts = {
    'terminee',
    'terminée',
    'termine',
    'terminé',
    'done',
    'completed',
    'realisee',
    'réalisée',
  };

  Future<void> create({
    required String bookingId,
    required String clientId,
    required int note,
    String? commentaire,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'review.create',
        action: () async {
          if (note < 1 || note > 5) {
            throw ArgumentError('La note doit être entre 1 et 5.');
          }

          final reservation = await _client
              .from('reservations')
              .select('client_id, prestataire_id, statut')
              .eq('id', bookingId)
              .maybeSingle();

          if (reservation == null) {
            throw StateError('Réservation introuvable.');
          }

          final row = Map<String, dynamic>.from(reservation);
          if (row['client_id'] != clientId) {
            throw StateError(
              'Seul le client de la réservation peut laisser un avis.',
            );
          }

          final statut =
              (row['statut'] as String? ?? '').trim().toLowerCase();
          if (!_completedStatuts.contains(statut)) {
            throw StateError(
              'La réservation doit être terminée pour laisser un avis.',
            );
          }

          final text = commentaire?.trim();
          await _client.from('avis').insert({
            'reservation_id': bookingId,
            'client_id': clientId,
            'prestataire_id': row['prestataire_id'],
            'note': note,
            if (text != null && text.isNotEmpty) 'commentaire': text,
          });
        },
      );

  Future<List<Review>> getByPrestataire(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'review.getByPrestataire',
        action: () async {
          final response = await _client
              .from('avis')
              .select()
              .eq('prestataire_id', prestataireId)
              .order('created_at', ascending: false);

          return [
            for (final raw in response as List<dynamic>)
              SupabaseDomainCodec.review(
                Map<String, dynamic>.from(raw as Map),
              ),
          ];
        },
      );

  Future<bool> hasReviewed(String bookingId) =>
      SupabaseErrorHandler.run(
        operation: 'review.hasReviewed',
        action: () async {
          final row = await _client
              .from('avis')
              .select('id')
              .eq('reservation_id', bookingId)
              .maybeSingle();
          return row != null;
        },
      );
}

bool reviewReservationIsCompleted(String statut) {
  final s = statut.trim().toLowerCase();
  return ReviewService._completedStatuts.contains(s);
}
