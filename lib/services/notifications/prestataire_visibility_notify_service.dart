import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../supabase/supabase_service.dart';

/// Push FCM : rappels visibilité prestataire (profil, carte, abonnement).
class PrestataireVisibilityNotifyService {
  PrestataireVisibilityNotifyService(this._client);

  final SupabaseClient _client;

  factory PrestataireVisibilityNotifyService.fromEnv() {
    return PrestataireVisibilityNotifyService(SupabaseService.client);
  }

  Future<bool> requestPushNudge({String? reason}) async {
    if (!AppConfig.hasSupabase) return false;
    try {
      final res = await _client.functions.invoke(
        'notify_prestataire_catalog_visibility',
        body: reason == null || reason.isEmpty ? null : {'reason': reason},
      );
      final data = res.data;
      if (data is Map && data['sent'] == true) return true;
      return false;
    } catch (_) {
      return false;
    }
  }
}
