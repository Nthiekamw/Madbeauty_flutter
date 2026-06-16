import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/admin/admin_catalog_trial_settings.dart';
import '../../../services/supabase/admin/admin_catalog_trial_service.dart';

final adminCatalogTrialServiceProvider =
    Provider<AdminCatalogTrialService?>((ref) {
  return AdminCatalogTrialService.fromEnv();
});

final adminCatalogTrialSettingsProvider =
    FutureProvider.autoDispose<AdminCatalogTrialSettings>((ref) async {
  final service = ref.watch(adminCatalogTrialServiceProvider);
  if (service == null) {
    return const AdminCatalogTrialSettings(
      catalogTrialDays: 90,
      prestatairesInTrial: 0,
      prestatairesExpiredWithoutSub: 0,
    );
  }
  return service.getSettings();
});

final adminPrestataireTrialsSearchProvider = FutureProvider.autoDispose
    .family<List<AdminPrestataireTrialSummary>, String>((ref, query) async {
  final service = ref.watch(adminCatalogTrialServiceProvider);
  if (service == null) return const [];
  return service.searchPrestataireTrials(query: query);
});
