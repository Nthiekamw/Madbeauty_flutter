import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/supabase_error_handler.dart';
import '../../core/models/user_role.dart';
import '../supabase/supabase_service.dart';

class RoleService {
  RoleService(this._client);

  final SupabaseClient _client;

  factory RoleService.fromEnv() => RoleService(SupabaseService.client);

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
          await _client.from('user_roles').insert({
            'user_id': user.id,
            'role': role.value,
          });
        } on PostgrestException catch (e) {
          // Idempotence: rôle déjà présent (PK user_id, role).
          if (e.code == '23505') return;
          rethrow;
        }
      },
    );
  }
}
