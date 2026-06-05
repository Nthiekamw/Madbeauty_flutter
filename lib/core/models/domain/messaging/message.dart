import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'message.freezed.dart';
part 'message.g.dart';

/// [MESSAGES] – lié à une réservation ([bookingId]).
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    @JsonKey(name: 'booking_id') required String bookingId,
    @JsonKey(name: 'sender_id') required String senderId,
    required String content,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
    @JsonKey(name: 'created_at')
    @IsoDateTimeConverter()
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

extension MessageCompat on Message {
  /// Alias historique (conversation_id supprimé du modèle).
  String get contenu => content;
}

