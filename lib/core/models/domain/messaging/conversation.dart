import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// [CONVERSATIONS]
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String clientId,
    required String prestataireId,
    @NullableIsoDateTimeConverter() DateTime? lastMessageAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
