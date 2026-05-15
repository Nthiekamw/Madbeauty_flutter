import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/user/user_profile.dart';

class ProfileService {
  ProfileService(this._client);

  final SupabaseClient _client;

  Future<UserProfile?> getById(String id) => SupabaseErrorHandler.run(
        operation: 'profile.getById',
        action: () async {
          final response = await _client
              .from('user_profiles')
              .select()
              .eq('id', id)
              .maybeSingle();
          if (response == null) return null;
          return UserProfile.fromJson(Map<String, dynamic>.from(response));
        },
      );

  Future<UserProfile?> getByUserId(String userId) => SupabaseErrorHandler.run(
        operation: 'profile.getByUserId',
        action: () async {
          final response = await _client
              .from('user_profiles')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
          if (response == null) return null;
          return UserProfile.fromJson(Map<String, dynamic>.from(response));
        },
      );

  Future<Map<String, UserProfile>> getByUserIds(List<String> userIds) async {
    if (userIds.isEmpty) return const {};
    return SupabaseErrorHandler.run(
      operation: 'profile.getByUserIds',
      action: () async {
        final response = await _client
            .from('user_profiles')
            .select()
            .inFilter('user_id', userIds);
        final out = <String, UserProfile>{};
        for (final row in response as List<dynamic>) {
          final profile = UserProfile.fromJson(row as Map<String, dynamic>);
          out[profile.userId] = profile;
        }
        return out;
      },
    );
  }

  Future<void> update(UserProfile profile) => SupabaseErrorHandler.run(
        operation: 'profile.update',
        action: () async {
          await _client
              .from('user_profiles')
              .update({
                'nom': profile.nom,
                'prenom': profile.prenom,
                'avatar_url': profile.avatarUrl,
                'telephone': profile.telephone,
              })
              .eq('id', profile.id);
        },
      );

  Future<void> upsertAvatar({
    required String userId,
    required String avatarUrl,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'profile.upsertAvatar',
        action: () async {
          await _client.from('user_profiles').upsert(
            {
              'user_id': userId,
              'avatar_url': avatarUrl,
            },
            onConflict: 'user_id',
          );
        },
      );
}
