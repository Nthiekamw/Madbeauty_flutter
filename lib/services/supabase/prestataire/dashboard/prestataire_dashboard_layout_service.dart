import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/prestataire/prestataire_dashboard_layout.dart';
import '../../../storage/local_cache_service.dart';

/// Lecture / écriture de [prestataire_profiles.dashboard_layout].
class PrestataireDashboardLayoutService {
  PrestataireDashboardLayoutService(this._client);

  final SupabaseClient _client;

  static String _cacheKey(String prestataireId) =>
      'prestataire.dashboard_layout.$prestataireId';

  PrestataireDashboardLayout _readLocal(String prestataireId) {
    final raw = LocalCacheService.instance.getString(_cacheKey(prestataireId));
    if (raw == null || raw.isEmpty) return PrestataireDashboardLayout.defaults;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return PrestataireDashboardLayout.fromJson(decoded);
      }
    } catch (_) {}
    return PrestataireDashboardLayout.defaults;
  }

  Future<void> _writeLocal(
    String prestataireId,
    PrestataireDashboardLayout layout,
  ) async {
    await LocalCacheService.instance.setString(
      _cacheKey(prestataireId),
      jsonEncode(layout.toJson()),
    );
  }

  Future<PrestataireDashboardLayout> load(String prestataireId) async {
    final cached = _readLocal(prestataireId);
    if (!AppConfig.hasSupabase) return cached;

    return SupabaseErrorHandler.run(
      operation: 'prestataireDashboardLayout.load',
      action: () async {
        final row = await _client
            .from('prestataire_profiles')
            .select('dashboard_layout')
            .eq('id', prestataireId)
            .maybeSingle();

        if (row == null) return cached;

        final raw = row['dashboard_layout'];
        if (raw == null) return cached;

        final map = raw is Map<String, dynamic>
            ? raw
            : Map<String, dynamic>.from(raw as Map);
        final layout = PrestataireDashboardLayout.fromJson(map);
        await _writeLocal(prestataireId, layout);
        return layout;
      },
    );
  }

  Future<void> save(
    String prestataireId,
    PrestataireDashboardLayout layout,
  ) async {
    await _writeLocal(prestataireId, layout);
    if (!AppConfig.hasSupabase) return;

    await SupabaseErrorHandler.run(
      operation: 'prestataireDashboardLayout.save',
      action: () async {
        await _client
            .from('prestataire_profiles')
            .update({'dashboard_layout': layout.toJson()})
            .eq('id', prestataireId);
      },
    );
  }
}

