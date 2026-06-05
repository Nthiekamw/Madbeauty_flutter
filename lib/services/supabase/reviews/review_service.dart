import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/reviews/review.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../features/reviews/models/client_review_list_item.dart';
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

  static const maxReviewPhotos = 3;

  Future<String> create({
    required String bookingId,
    required String clientId,
    required int note,
    String? commentaire,
    List<String> photoUrls = const [],
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
          final urls = photoUrls
              .map((u) => u.trim())
              .where((u) => u.isNotEmpty)
              .take(maxReviewPhotos)
              .toList();

          final inserted = await _client
              .from('avis')
              .insert({
                'reservation_id': bookingId,
                'client_id': clientId,
                'prestataire_id': row['prestataire_id'],
                'note': note,
                if (text != null && text.isNotEmpty) 'commentaire': text,
                'photo_urls': urls,
              })
              .select('id')
              .single();

          return Map<String, dynamic>.from(inserted)['id'] as String;
        },
      );

  Future<void> attachPhotoUrls({
    required String reviewId,
    required String clientId,
    required List<String> photoUrls,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'review.attachPhotoUrls',
        action: () async {
          final urls = photoUrls
              .map((u) => u.trim())
              .where((u) => u.isNotEmpty)
              .take(maxReviewPhotos)
              .toList();
          await _client
              .from('avis')
              .update({'photo_urls': urls})
              .eq('id', reviewId)
              .eq('client_id', clientId);
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

  Future<List<ClientReviewListItem>> listForClient(String clientId) =>
      SupabaseErrorHandler.run(
        operation: 'review.listForClient',
        action: () async {
          final response = await _client
              .from('avis')
              .select(
                'id, client_id, prestataire_id, reservation_id, note, '
                'commentaire, photo_urls, created_at, '
                'prestataire_profiles(nom_salon), '
                'reservations(date_heure, services_beaute(nom))',
              )
              .eq('client_id', clientId)
              .order('created_at', ascending: false);

          return [
            for (final raw in response as List<dynamic>)
              _clientReviewListItemFromRow(
                Map<String, dynamic>.from(raw as Map),
              ),
          ];
        },
      );

  Future<void> update({
    required String reviewId,
    required String clientId,
    required int note,
    String? commentaire,
    List<String>? photoUrls,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'review.update',
        action: () async {
          if (note < 1 || note > 5) {
            throw ArgumentError('La note doit être entre 1 et 5.');
          }

          final existing = await _client
              .from('avis')
              .select('id, client_id, created_at')
              .eq('id', reviewId)
              .maybeSingle();

          if (existing == null) {
            throw StateError('Avis introuvable.');
          }

          final row = Map<String, dynamic>.from(existing);
          if (row['client_id'] != clientId) {
            throw StateError('Tu ne peux modifier que tes propres avis.');
          }

          final createdAt = DateTime.parse(row['created_at'] as String);
          if (DateTime.now().difference(createdAt) >=
              ClientReviewListItem.editWindow) {
            throw StateError('Le délai de modification est dépassé.');
          }

          final text = commentaire?.trim();
          final payload = <String, dynamic>{'note': note};
          if (text != null && text.isNotEmpty) {
            payload['commentaire'] = text;
          } else {
            payload['commentaire'] = null;
          }
          if (photoUrls != null) {
            payload['photo_urls'] = photoUrls
                .map((u) => u.trim())
                .where((u) => u.isNotEmpty)
                .take(maxReviewPhotos)
                .toList();
          }

          await _client
              .from('avis')
              .update(payload)
              .eq('id', reviewId)
              .eq('client_id', clientId);
        },
      );

  ClientReviewListItem _clientReviewListItemFromRow(Map<String, dynamic> map) {
    final prestataire = map['prestataire_profiles'];
    final reservation = map['reservations'];
    Object? service;
    if (reservation is Map) {
      service = reservation['services_beaute'];
    }

    DateTime? reservationDate;
    if (reservation is Map && reservation['date_heure'] != null) {
      reservationDate =
          DateTime.tryParse(reservation['date_heure'] as String)?.toLocal();
    }

    return ClientReviewListItem(
      review: SupabaseDomainCodec.review(map),
      prestataireName:
          prestataire is Map ? prestataire['nom_salon'] as String? : null,
      serviceName: service is Map ? service['nom'] as String? : null,
      reservationDate: reservationDate,
    );
  }
}

bool reviewReservationIsCompleted(String statut) {
  final s = statut.trim().toLowerCase();
  return ReviewService._completedStatuts.contains(s);
}

