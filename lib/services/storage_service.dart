import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Accès au bucket Supabase Storage (à brancher sur ton schéma).
class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;

  factory StorageService.fromEnv() =>
      StorageService(SupabaseService.client);

  SupabaseStorageClient get storage => _client.storage;
}
