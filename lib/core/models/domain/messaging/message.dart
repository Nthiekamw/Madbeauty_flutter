import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// [MESSAGES]
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    required String senderId,
    required String contenu,
    @Default(false) bool isRead,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
