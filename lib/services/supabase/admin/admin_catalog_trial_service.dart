import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_catalog_trial_settings.dart';
import '../supabase_service.dart';

class AdminCatalogTrialService {
  AdminCatalogTrialService(this._client);

  final SupabaseClient _client;

  factory AdminCatalogTrialService.fromEnv() =>
      AdminCatalogTrialService(SupabaseService.client);

  Future<AdminCatalogTrialSettings> getSettings() async {
    return SupabaseErrorHandler.run(
      operation: 'adminCatalogTrial.getSettings',
      action: () async {
        final result = await _client.rpc('admin_get_catalog_trial_settings');
        if (result is Map<String, dynamic>) {
          return AdminCatalogTrialSettings.fromJson(result);
        }
        if (result is Map) {
          return AdminCatalogTrialSettings.fromJson(
            Map<String, dynamic>.from(result),
          );
        }
        return const AdminCatalogTrialSettings(
          catalogTrialDays: 90,
          prestatairesInTrial: 0,
          prestatairesExpiredWithoutSub: 0,
        );
      },
    );
  }

  Future<AdminCatalogTrialSettings> updateTrialDays(int days) async {
    return SupabaseErrorHandler.run(
      operation: 'adminCatalogTrial.updateTrialDays',
      action: () async {
        final result = await _client.rpc(
          'admin_update_catalog_trial_days',
          params: {'p_days': days},
        );
        if (result is Map<String, dynamic>) {
          return AdminCatalogTrialSettings.fromJson(result);
        }
        if (result is Map) {
          return AdminCatalogTrialSettings.fromJson(
            Map<String, dynamic>.from(result),
          );
        }
        return getSettings();
      },
    );
  }

  Future<int> applyDefaultTrialToUnsubscribed() async {
    return SupabaseErrorHandler.run(
      operation: 'adminCatalogTrial.applyDefaultTrialToUnsubscribed',
      action: () async {
        final result =
            await _client.rpc('admin_apply_default_trial_to_unsubscribed');
        if (result is num) return result.toInt();
        return int.tryParse('$result') ?? 0;
      },
    );
  }

  Future<DateTime> extendPrestataireTrial({
    required String prestataireId,
    required int extraDays,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminCatalogTrial.extendPrestataireTrial',
      action: () async {
        final result = await _client.rpc(
          'admin_extend_prestataire_catalog_trial',
          params: {
            'p_prestataire_id': prestataireId,
            'p_extra_days': extraDays,
          },
        );
        final parsed = DateTime.tryParse('$result');
        if (parsed == null) {
          throw StateError('Invalid trial end date from server');
        }
        return parsed;
      },
    );
  }

  Future<List<AdminPrestataireTrialSummary>> searchPrestataireTrials({
    String query = '',
    int limit = 30,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminCatalogTrial.searchPrestataireTrials',
      action: () async {
        final rows = await _client.rpc(
          'admin_search_prestataire_trials',
          params: {'p_query': query, 'p_limit': limit},
        );
        if (rows is! List) return const [];
        return rows
            .map(
              (row) => AdminPrestataireTrialSummary.fromJson(
                Map<String, dynamic>.from(row as Map),
              ),
            )
            .toList();
      },
    );
  }
}
