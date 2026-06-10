import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../services/supabase/prestataire/dashboard/prestataire_dashboard_layout_service.dart';
import '../../../../services/supabase/supabase_service.dart';
import '../../models/prestataire_dashboard_layout.dart';
import '../../models/prestataire_dashboard_section_id.dart';
import '../../models/prestataire_dashboard_data.dart';
import '../profile/current_prestataire_provider.dart';
final prestataireDashboardLayoutServiceProvider =
    Provider<PrestataireDashboardLayoutService?>((ref) {
      if (!AppConfig.hasSupabase) return null;
      return PrestataireDashboardLayoutService(SupabaseService.client);
    });

class PrestataireDashboardLayoutNotifier
    extends AsyncNotifier<PrestataireDashboardLayout> {
  String? _prestataireId;

  @override
  Future<PrestataireDashboardLayout> build() async {
    final presta = await ref.watch(currentPrestataireProvider.future);
    if (presta == null) return PrestataireDashboardLayout.defaults;
    _prestataireId = presta.id;

    final service = ref.watch(prestataireDashboardLayoutServiceProvider);
    if (service == null) return PrestataireDashboardLayout.defaults;
    try {
      return await service.load(presta.id);
    } catch (_) {
      return PrestataireDashboardLayout.defaults;
    }
  }

  Future<void> _persist(PrestataireDashboardLayout layout) async {
    final id = _prestataireId;
    if (id == null) return;
    final service = ref.read(prestataireDashboardLayoutServiceProvider);
    if (service == null) return;
    await service.save(id, layout);
  }

  Future<void> toggleCollapsed(PrestataireDashboardSectionId sectionId) async {
    final current = state.asData?.value;
    if (current == null) return;
    final next = current.withCollapsed(
      sectionId,
      !current.isCollapsed(sectionId),
    );
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> reorderVisible(
    List<PrestataireDashboardSectionId> visible, {
    required int oldIndex,
    required int newIndex,
  }) async {
    final current = state.asData?.value;
    if (current == null) return;
    final next = current.reorderVisible(
      visible,
      oldIndex: oldIndex,
      newIndex: newIndex,
    );
    state = AsyncData(next);
    await _persist(next);
  }
}

final prestataireDashboardLayoutProvider = AsyncNotifierProvider<
  PrestataireDashboardLayoutNotifier,
  PrestataireDashboardLayout
>(PrestataireDashboardLayoutNotifier.new);

/// Sections visibles selon les données chargées.
List<PrestataireDashboardSectionId> visiblePrestataireDashboardSections({
  required PrestataireDashboardLayout layout,
  required bool profileLoaded,
  required bool dashboardLoaded,
  required PrestataireDashboardData? dashboard,
}) {
  final out = <PrestataireDashboardSectionId>[];
  for (final id in layout.order) {
    switch (id) {
      case PrestataireDashboardSectionId.hero:
      case PrestataireDashboardSectionId.stats:
        break;
      case PrestataireDashboardSectionId.analytics:
        if (profileLoaded) out.add(id);
      case PrestataireDashboardSectionId.pending:
        if (dashboardLoaded) out.add(id);
      case PrestataireDashboardSectionId.today:
        if (dashboardLoaded) out.add(id);
      case PrestataireDashboardSectionId.week:
        if (dashboardLoaded &&
            dashboard != null &&
            dashboard.weekConfirmed.isNotEmpty) {
          out.add(id);
        }
    }
  }
  return out;
}

