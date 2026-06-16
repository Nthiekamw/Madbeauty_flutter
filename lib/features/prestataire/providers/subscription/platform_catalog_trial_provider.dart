import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/prestataire_subscription_config.dart';
import '../../../../services/supabase/platform/platform_settings_service.dart';

final platformSettingsServiceProvider = Provider<PlatformSettingsService?>((ref) {
  return PlatformSettingsService.fromEnv();
});

/// Durée d’essai catalogue configurée sur la plateforme (nouveaux profils).
final platformCatalogTrialDaysProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(platformSettingsServiceProvider);
  if (service == null) return PrestataireSubscriptionConfig.catalogTrialDays;
  try {
    return await service.getCatalogTrialDays();
  } catch (_) {
    return PrestataireSubscriptionConfig.catalogTrialDays;
  }
});
