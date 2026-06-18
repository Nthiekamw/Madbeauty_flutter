import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_user_support_thread.dart';
import '../supabase_service.dart';

class AdminUserSupportService {
  AdminUserSupportService(this._client);

  final SupabaseClient _client;

  factory AdminUserSupportService.fromEnv() =>
      AdminUserSupportService(SupabaseService.client);

  Future<List<AdminUserSupportThread>> listThreads({int limit = 50}) async {
    return SupabaseErrorHandler.run(
      operation: 'adminUserSupport.listThreads',
      action: () async {
        final rows = await _client.rpc(
          'admin_list_user_support_threads',
          params: {'p_limit': limit},
        );
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        if (list.isEmpty) return const [];
        return list.map(AdminUserSupportThread.fromRow).toList();
      },
    );
  }
}
