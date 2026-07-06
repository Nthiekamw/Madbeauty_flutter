import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/supabase_error_handler.dart';
import '../supabase/supabase_service.dart';

/// Demande de suppression de compte (traitée par un admin).
class AccountDeletionService {
  AccountDeletionService(this._client);

  final SupabaseClient _client;

  factory AccountDeletionService.fromEnv() =>
      AccountDeletionService(SupabaseService.client);

  Future<void> requestAccountDeletion() async {
    await SupabaseErrorHandler.run(
      operation: 'accountDeletion.request',
      action: () async {
        await _client.rpc('request_account_deletion');
      },
    );
  }
}
