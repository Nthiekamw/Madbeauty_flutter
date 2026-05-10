import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

/// [RESERVATIONS] — `statut` reste une chaîne (ex. confirmée, annulée) pour coller au schéma.
@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String clientId,
    required String prestataireId,
    required String serviceId,
    @IsoDateTimeConverter() required DateTime dateHeure,
    required String statut,
    String? notesClient,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}
