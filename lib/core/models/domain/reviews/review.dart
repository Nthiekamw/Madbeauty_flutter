import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';
import 'avis.dart';

part 'review.freezed.dart';
part 'review.g.dart';

/// Avis client sur une prestation terminée ([bookingId] = `reservations.id`).
@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required String clientId,
    required String prestataireId,
    @JsonKey(name: 'reservation_id') required String bookingId,
    required int note,
    String? commentaire,
    @JsonKey(name: 'created_at')
    @IsoDateTimeConverter()
    required DateTime createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  factory Review.fromAvis(Avis avis) => Review(
        id: avis.id,
        clientId: avis.clientId,
        prestataireId: avis.prestataireId,
        bookingId: avis.reservationId,
        note: avis.note,
        commentaire: avis.commentaire,
        createdAt: avis.createdAt,
      );
}
