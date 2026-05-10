import 'package:freezed_annotation/freezed_annotation.dart';

import '../serialization/json_converters.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Entité [USERS] du schéma métier (hors `auth.users` Supabase si vous séparez les tables).
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    /// Ne devrait pas être exposé par l’API publique ; utile seulement pour des DTO serveur.
    String? passwordHash,
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
}
