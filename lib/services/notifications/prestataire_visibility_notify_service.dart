import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../supabase/supabase_service.dart';

/// Push FCM : rappel d’abonnement pour visibilité catalogue.
class PrestataireVisibilityNotifyService {
  PrestataireVisibilityNotifyService(this._client);

  final SupabaseClient _client;

  factory PrestataireVisibilityNotifyService.fromEnv() {
    return PrestataireVisibilityNotifyService(SupabaseService.client);
  }

  Future<bool> requestPushNudge() async {
    if (!AppConfig.hasSupabase) return false;
    try {
      final res = await _client.functions.invoke(
        'notify_prestataire_catalog_visibility',
      );
      final data = res.data;
      if (data is Map && data['sent'] == true) return true;
      return false;
    } catch (_) {
      return false;
    }
  }
}
