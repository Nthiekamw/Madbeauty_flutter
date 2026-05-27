// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      prestataireId: json['prestataire_id'] as String,
      reservationId: json['reservation_id'] as String,
      lastMessageAt: const NullableIsoDateTimeConverter().fromJson(
        json['last_message_at'],
      ),
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'client_id': instance.clientId,
      'prestataire_id': instance.prestataireId,
      'reservation_id': instance.reservationId,
      'last_message_at': const NullableIsoDateTimeConverter().toJson(
        instance.lastMessageAt,
      ),
    };
