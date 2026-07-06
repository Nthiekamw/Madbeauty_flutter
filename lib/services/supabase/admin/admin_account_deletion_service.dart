import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_account_deletion_request.dart';
import '../supabase_service.dart';

class AdminAccountDeletionService {
  AdminAccountDeletionService(this._client);

  final SupabaseClient _client;

  factory AdminAccountDeletionService.fromEnv() =>
      AdminAccountDeletionService(SupabaseService.client);

  Future<List<AdminAccountDeletionRequest>> listPendingRequests() async {
    return SupabaseErrorHandler.run(
      operation: 'adminAccountDeletion.listPending',
      action: () async {
        final rows = await _client.rpc('admin_list_account_deletion_requests');
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        return list.map(_mapRow).toList();
      },
    );
  }

  Future<void> executeDeletion({required String userId}) async {
    await SupabaseErrorHandler.run(
      operation: 'adminAccountDeletion.execute',
      action: () async {
        await _client.rpc(
          'admin_execute_account_deletion',
          params: {'p_user_id': userId},
        );
      },
    );
  }

  AdminAccountDeletionRequest _mapRow(Map<String, dynamic> row) {
    final rolesRaw = row['roles'];
    final roles = switch (rolesRaw) {
      List<dynamic> list => list.map((e) => '$e').toList(),
      _ => const <String>[],
    };
    return AdminAccountDeletionRequest(
      userId: row['user_id'] as String? ?? '',
      email: row['email'] as String? ?? '',
      prenom: row['prenom'] as String?,
      nom: row['nom'] as String?,
      requestedAt: DateTime.tryParse((row['requested_at'] as String?) ?? ''),
      roles: roles,
    );
  }
}
