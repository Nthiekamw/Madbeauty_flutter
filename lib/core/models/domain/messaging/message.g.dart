// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  bookingId: json['booking_id'] as String,
  senderId: json['sender_id'] as String,
  content: json['content'] as String,
  imageUrl: json['image_url'] as String?,
  isRead: json['is_read'] as bool? ?? false,
  createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'booking_id': instance.bookingId,
  'sender_id': instance.senderId,
  'content': instance.content,
  'image_url': instance.imageUrl,
  'is_read': instance.isRead,
  'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
};
