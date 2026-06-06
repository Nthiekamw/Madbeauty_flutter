import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../features/admin/models/admin_user_summary.dart';
import '../supabase_service.dart';

class AdminUsersService {
  AdminUsersService(this._client);

  final SupabaseClient _client;

  factory AdminUsersService.fromEnv() =>
      AdminUsersService(SupabaseService.client);

  Future<List<AdminUserSummary>> searchUsers({
    String query = '',
    int limit = 50,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminUsers.searchUsers',
      action: () async {
        final rows = await _client.rpc(
          'admin_search_users',
          params: {'p_query': query, 'p_limit': limit},
        );
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(_mapRow).toList();
      },
    );
  }

  Future<void> setUserRole({
    required String userId,
    required String role,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'adminUsers.setUserRole',
      action: () async {
        await _client.rpc(
          'admin_set_user_role',
          params: {'p_user_id': userId, 'p_role': role},
        );
      },
    );
  }

  Future<void> removeUserRole({
    required String userId,
    required String role,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'adminUsers.removeUserRole',
      action: () async {
        await _client.rpc(
          'admin_remove_user_role',
          params: {'p_user_id': userId, 'p_role': role},
        );
      },
    );
  }

  Future<void> banUser({
    required String userId,
    String? reason,
  }) async {
    await SupabaseErrorHandler.run(
      operation: 'adminUsers.banUser',
      action: () async {
        await _client.rpc(
          'admin_ban_user',
          params: {'p_user_id': userId, 'p_reason': reason},
        );
      },
    );
  }

  Future<void> unbanUser({required String userId}) async {
    await SupabaseErrorHandler.run(
      operation: 'adminUsers.unbanUser',
      action: () async {
        await _client.rpc(
          'admin_unban_user',
          params: {'p_user_id': userId},
        );
      },
    );
  }

  AdminUserSummary _mapRow(Map<String, dynamic> row) {
    final rolesRaw = row['roles'];
    final roles = switch (rolesRaw) {
      List<dynamic> list => list.map((e) => '$e').toList(),
      _ => const <String>[],
    };
    return AdminUserSummary(
      userId: row['user_id'] as String? ?? '',
      email: row['email'] as String? ?? '',
      prenom: row['prenom'] as String?,
      nom: row['nom'] as String?,
      isBanned: row['is_banned'] as bool? ?? false,
      bannedAt: DateTime.tryParse((row['banned_at'] as String?) ?? ''),
      banReason: row['ban_reason'] as String?,
      roles: roles,
    );
  }
}
