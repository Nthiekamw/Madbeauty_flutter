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

  Future<void> upsertClientDetails({
    required String userId,
    required String prenom,
    required String nom,
    String? telephone,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'profile.upsertClientDetails',
        action: () async {
          final p = prenom.trim();
          final n = nom.trim();
          await _client.from('user_profiles').upsert(
            {
              'user_id': userId,
              if (p.isNotEmpty) 'prenom': p,
              if (n.isNotEmpty) 'nom': n,
              if (telephone != null && telephone.trim().isNotEmpty)
                'telephone': telephone.trim(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            },
            onConflict: 'user_id',
          );
        },
      );

  Future<void> upsertIdentity({
    required String userId,
    String? prenom,
    String? nom,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'profile.upsertIdentity',
        action: () async {
          final p = prenom?.trim();
          final n = nom?.trim();
          await _client.from('user_profiles').upsert(
            {
              'user_id': userId,
              if (p != null && p.isNotEmpty) 'prenom': p,
              if (n != null && n.isNotEmpty) 'nom': n,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            },
            onConflict: 'user_id',
          );
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

  Future<void> upsertFcmToken({
    required String userId,
    required String token,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'profile.upsertFcmToken',
        action: () async {
          final currentUserId = _client.auth.currentUser?.id;
          if (currentUserId == null || currentUserId != userId) {
            return;
          }
          await _client
              .from('user_profiles')
              .update({
                'fcm_token': token,
                'fcm_token_updated_at':
                    DateTime.now().toUtc().toIso8601String(),
              })
              .eq('user_id', userId);
        },
      );

  Future<void> clearFcmToken({required String userId}) =>
      SupabaseErrorHandler.run(
        operation: 'profile.clearFcmToken',
        action: () async {
          final currentUserId = _client.auth.currentUser?.id;
          if (currentUserId == null || currentUserId != userId) {
            return;
          }
          await _client.from('user_profiles').update({
            'fcm_token': null,
            'fcm_token_updated_at': DateTime.now().toUtc().toIso8601String(),
          }).eq('user_id', userId);
        },
      );
}

