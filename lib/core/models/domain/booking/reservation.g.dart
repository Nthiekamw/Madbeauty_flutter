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
  amountCents: (json['amount_cents'] as num?)?.toInt(),
  currency: json['currency'] as String?,
  stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
  paymentStatus: json['payment_status'] as String?,
  paidAt: const NullableIsoDateTimeConverter().fromJson(json['paid_at']),
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
      'amount_cents': instance.amountCents,
      'currency': instance.currency,
      'stripe_payment_intent_id': instance.stripePaymentIntentId,
      'payment_status': instance.paymentStatus,
      'paid_at': const NullableIsoDateTimeConverter().toJson(instance.paidAt),
      'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
    };
