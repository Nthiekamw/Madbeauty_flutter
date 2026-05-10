// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  senderId: json['sender_id'] as String,
  contenu: json['contenu'] as String,
  isRead: json['is_read'] as bool? ?? false,
  createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'sender_id': instance.senderId,
  'contenu': instance.contenu,
  'is_read': instance.isRead,
  'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
};
