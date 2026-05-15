import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../core/models/domain/user/client_profile.dart';

class ClientProfileService {
  ClientProfileService(this._client);

  final SupabaseClient _client;

  Future<ClientProfile?> getByUserId(String userId) => SupabaseErrorHandler.run(
        operation: 'clientProfile.getByUserId',
        action: () async {
          final response = await _client
              .from('client_profiles')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
          if (response == null) return null;
          return SupabaseDomainCodec.clientProfile(
            Map<String, dynamic>.from(response),
          );
        },
      );
}
