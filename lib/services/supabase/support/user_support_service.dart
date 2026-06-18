import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../supabase_service.dart';

class UserSupportService {
  UserSupportService(this._client);

  final SupabaseClient _client;

  factory UserSupportService.fromEnv() =>
      UserSupportService(SupabaseService.client);

  Future<String> ensureMyThread() => SupabaseErrorHandler.run(
        operation: 'userSupport.ensureMyThread',
        action: () async {
          final result = await _client.rpc('ensure_user_support_thread');
          return result as String;
        },
      );
}
