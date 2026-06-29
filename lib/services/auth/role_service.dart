import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/supabase_error_handler.dart';
import '../../core/models/user_role.dart';
import '../supabase/supabase_service.dart';

class RoleService {
  RoleService(this._client);

  final SupabaseClient _client;

  factory RoleService.fromEnv() => RoleService(SupabaseService.client);

  static bool isDuplicateRoleError(PostgrestException error) {
    final code = error.code?.trim();
    if (code == '23505' || code == '409') return true;
    final message = error.message.toLowerCase();
    final details = error.details?.toString().toLowerCase() ?? '';
    return message.contains('duplicate') ||
        message.contains('unique') ||
        message.contains('already exists') ||
        details.contains('duplicate') ||
        details.contains('unique');
  }

  static bool isMissingRpcError(PostgrestException error) {
    final code = error.code?.trim();
    if (code == 'PGRST202' || code == '42883') return true;
    final message = error.message.toLowerCase();
    return message.contains('ensure_user_role') &&
        (message.contains('not find') ||
            message.contains('could not find') ||
            message.contains('does not exist'));
  }

  Future<List<UserRole>> getMyRoles() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];

    return SupabaseErrorHandler.run(
      operation: 'role.getMyRoles',
      action: () async {
        final rows = await _client
            .from('user_roles')
            .select('role')
            .eq('user_id', user.id);

        final roles = <UserRole>[];
        for (final row in rows as List<dynamic>) {
          final roleValue = (row as Map<String, dynamic>)['role'] as String?;
          if (roleValue == null) continue;
          final parsed = UserRole.fromValue(roleValue);
          if (parsed != null) roles.add(parsed);
        }
        return roles;
      },
    );
  }

  Future<void> ensureRole(UserRole role) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await SupabaseErrorHandler.run(
      operation: 'role.ensureRole',
      action: () async {
        try {
          await _client.rpc('ensure_user_role', params: {'p_role': role.value});
        } on PostgrestException catch (e) {
          if (isMissingRpcError(e)) {
            await _upsertRoleIgnoreDuplicates(userId: user.id, role: role);
            return;
          }
          if (isDuplicateRoleError(e)) return;
          rethrow;
        }
      },
    );
  }

  Future<void> _upsertRoleIgnoreDuplicates({
    required String userId,
    required UserRole role,
  }) async {
    try {
      await _client.from('user_roles').upsert(
        {
          'user_id': userId,
          'role': role.value,
        },
        onConflict: 'user_id,role',
        ignoreDuplicates: true,
      );
    } on PostgrestException catch (e) {
      if (isDuplicateRoleError(e)) return;
      rethrow;
    }
  }

  Future<void> removeRole(UserRole role) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await SupabaseErrorHandler.run(
      operation: 'role.removeRole',
      action: () async {
        await _client
            .from('user_roles')
            .delete()
            .eq('user_id', user.id)
            .eq('role', role.value);
      },
    );
  }
}

