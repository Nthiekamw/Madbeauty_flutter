import 'client_home_section_id.dart';

/// Ordre des blocs sur l'accueil client (cache local).
class ClientHomeLayout {
  const ClientHomeLayout({required this.order});

  final List<ClientHomeSectionId> order;

  static const layoutVersion = 8;

  static const defaultOrder = <ClientHomeSectionId>[
    ClientHomeSectionId.inspiration,
    ClientHomeSectionId.nextAppointment,
    ClientHomeSectionId.promo,
    ClientHomeSectionId.offers,
    ClientHomeSectionId.nearby,
    ClientHomeSectionId.topRated,
    ClientHomeSectionId.feed,
  ];

  static final defaults = ClientHomeLayout(
    order: List.unmodifiable(defaultOrder),
  );

  factory ClientHomeLayout.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return defaults;

    final version = json['version'] as int? ?? 1;
    if (version != layoutVersion) return defaults;

    final rawOrder = json['order'];
    final order = <ClientHomeSectionId>[];
    if (rawOrder is List) {
      for (final item in rawOrder) {
        final id = ClientHomeSectionId.tryParse(item?.toString());
        if (id == null || id == ClientHomeSectionId.loyalty) continue;
        if (!order.contains(id)) order.add(id);
      }
    }
    for (final id in defaultOrder) {
      if (!order.contains(id)) order.add(id);
    }

    return ClientHomeLayout(order: List.unmodifiable(order));
  }

  Map<String, dynamic> toJson() => {
        'version': layoutVersion,
        'order': order.map((e) => e.storageKey).toList(),
      };

  ClientHomeLayout reorderVisible(
    List<ClientHomeSectionId> visible, {
    required int oldIndex,
    required int newIndex,
  }) {
    if (visible.isEmpty || oldIndex == newIndex) return this;
    var target = newIndex;
    if (target > oldIndex) target -= 1;

    final nextVisible = List<ClientHomeSectionId>.from(visible);
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

    return ClientHomeLayout(order: List.unmodifiable(merged));
  }
}
