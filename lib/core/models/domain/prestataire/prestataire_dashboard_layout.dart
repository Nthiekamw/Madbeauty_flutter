import 'package:madbeauty/core/models/domain/prestataire/prestataire_dashboard_section_id.dart';

/// Ordre et état replié des sections du dashboard (sync Supabase).
class PrestataireDashboardLayout {
  const PrestataireDashboardLayout({
    required this.order,
    required this.collapsed,
  });

  final List<PrestataireDashboardSectionId> order;
  final Set<PrestataireDashboardSectionId> collapsed;

  static const defaultOrder = <PrestataireDashboardSectionId>[
    PrestataireDashboardSectionId.pending,
    PrestataireDashboardSectionId.today,
    PrestataireDashboardSectionId.week,
    PrestataireDashboardSectionId.analytics,
  ];

  static final defaults = PrestataireDashboardLayout(
    order: List.unmodifiable(defaultOrder),
    collapsed: const {},
  );

  factory PrestataireDashboardLayout.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return defaults;

    final rawOrder = json['order'];
    final order = <PrestataireDashboardSectionId>[];
    if (rawOrder is List) {
      for (final item in rawOrder) {
        final id = PrestataireDashboardSectionId.tryParse(item?.toString());
        if (id != null && !order.contains(id)) order.add(id);
      }
    }
    for (final id in defaultOrder) {
      if (!order.contains(id)) order.add(id);
    }

    final collapsed = <PrestataireDashboardSectionId>{};
    final rawCollapsed = json['collapsed'];
    if (rawCollapsed is List) {
      for (final item in rawCollapsed) {
        final id = PrestataireDashboardSectionId.tryParse(item?.toString());
        if (id != null) collapsed.add(id);
      }
    }

    return PrestataireDashboardLayout(
      order: List.unmodifiable(order),
      collapsed: Set.unmodifiable(collapsed),
    );
  }

  Map<String, dynamic> toJson() => {
        'order': order.map((e) => e.storageKey).toList(),
        'collapsed': collapsed.map((e) => e.storageKey).toList(),
      };

  bool isCollapsed(PrestataireDashboardSectionId id) => collapsed.contains(id);

  PrestataireDashboardLayout withCollapsed(
    PrestataireDashboardSectionId id,
    bool value,
  ) {
    final next = Set<PrestataireDashboardSectionId>.from(collapsed);
    if (value) {
      next.add(id);
    } else {
      next.remove(id);
    }
    return PrestataireDashboardLayout(order: order, collapsed: next);
  }

  /// Réordonne la liste [visible] (indices ReorderableListView).
  PrestataireDashboardLayout reorderVisible(
    List<PrestataireDashboardSectionId> visible, {
    required int oldIndex,
    required int newIndex,
  }) {
    if (visible.isEmpty || oldIndex == newIndex) return this;
    var target = newIndex;
    if (target > oldIndex) target -= 1;

    final nextVisible = List<PrestataireDashboardSectionId>.from(visible);
    final moved = nextVisible.removeAt(oldIndex);
    nextVisible.insert(target, moved);

    final visibleSet = nextVisible.toSet();
    final hidden = order.where((id) => !visibleSet.contains(id)).toList();
    var vi = 0;
    final merged = order.map((id) {
      if (visibleSet.contains(id)) {
        return nextVisible[vi++];
      }
      return id;
    }).toList();
    for (final id in hidden) {
      if (!merged.contains(id)) merged.add(id);
    }

    return PrestataireDashboardLayout(
      order: List.unmodifiable(merged),
      collapsed: collapsed,
    );
  }
}
