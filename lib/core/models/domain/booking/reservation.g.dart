// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reservation _$ReservationFromJson(Map<String, dynamic> json) => _Reservation(
  id: json['id'] as String,
  clientId: json['client_id'] as String,
  prestataireId: json['prestataire_id'] as String,
  serviceId: json['service_id'] as String,
  dateHeure: const IsoDateTimeConverter().fromJson(json['date_heure']),
  statut: json['statut'] as String,
  notesClient: json['notes_client'] as String?,
  createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$ReservationToJson(_Reservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_id': instance.clientId,
      'prestataire_id': instance.prestataireId,
      'service_id': instance.serviceId,
      'date_heure': const IsoDateTimeConverter().toJson(instance.dateHeure),
      'statut': instance.statut,
      'notes_client': instance.notesClient,
      'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
    };
