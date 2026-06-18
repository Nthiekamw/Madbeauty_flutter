import '../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';

/// Spécialités affichées sous une famille de service (Coiffure, Manucure…).
class PrestataireSpecialtyServiceGroup {
  const PrestataireSpecialtyServiceGroup({
    required this.main,
    required this.serviceTitle,
    required this.specialtyNames,
  });

  final PrestaMainService main;
  final String serviceTitle;
  final List<String> specialtyNames;
}

/// Prestations regroupées par famille de service.
class PrestataireServiceMainGroup {
  const PrestataireServiceMainGroup({
    required this.title,
    required this.services,
    this.main,
  });

  final PrestaMainService? main;
  final String title;
  final List<ServiceBeaute> services;
}

PrestaMainService? guessMainServiceFromLabel(String label) {
  final lower = label.trim().toLowerCase();
  if (lower.isEmpty) return null;
  if (lower.contains('manuc') || lower.contains('ongle')) {
    return PrestaMainService.manucure;
  }
  if (lower.contains('maquill')) return PrestaMainService.maquillage;
  if (lower.contains('pédic') || lower.contains('pedic')) {
    return PrestaMainService.pedicure;
  }
  if (lower.contains('coiff') ||
      lower.contains('tresse') ||
      lower.contains('lock') ||
      lower.contains('coupe') ||
      lower.contains('capillaire') ||
      lower.contains('afro')) {
    return PrestaMainService.coiffure;
  }
  return null;
}

String _specialtyLabelForCategory(String categoryId, List<ServiceBeaute> services) {
  final fromService = services
      .where((s) => s.categorieId == categoryId)
      .map((s) => s.nom.trim())
      .where((n) => n.isNotEmpty)
      .toList();
  if (fromService.isNotEmpty) return fromService.first;

  final catalog = PrestataireServiceCatalog.specialtyByCategoryId(categoryId);
  if (catalog != null && catalog.label.trim().isNotEmpty) {
    return catalog.label.trim();
  }
  return '';
}

PrestaMainService? _mainForService(ServiceBeaute service) {
  final cid = service.categorieId?.trim();
  if (cid != null && cid.isNotEmpty) {
    return PrestataireServiceCatalog.mainForCategoryId(cid);
  }
  return guessMainServiceFromLabel(service.nom);
}

/// Regroupe les spécialités déclarées + prestations par famille de service.
List<PrestataireSpecialtyServiceGroup> buildPrestataireSpecialtyGroups({
  required Set<String> categoryIds,
  required List<ServiceBeaute> services,
}) {
  final byMain = <PrestaMainService, Set<String>>{};

  void add(PrestaMainService main, String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    byMain.putIfAbsent(main, () => {}).add(trimmed);
  }

  for (final cid in categoryIds) {
    final main = PrestataireServiceCatalog.mainForCategoryId(cid);
    if (main == null) continue;
    add(main, _specialtyLabelForCategory(cid, services));
  }

  for (final service in services) {
    final main = _mainForService(service);
    if (main != null) add(main, service.nom);
  }

  return [
    for (final main in PrestaMainService.values)
      if (byMain[main]?.isNotEmpty ?? false)
        PrestataireSpecialtyServiceGroup(
          main: main,
          serviceTitle: PrestataireServiceCatalog.label(main),
          specialtyNames: byMain[main]!.toList()..sort(),
        ),
  ];
}

/// Regroupe les prestations réservables par famille de service.
List<PrestataireServiceMainGroup> groupServicesByMain(
  List<ServiceBeaute> services, {
  required String otherGroupTitle,
}) {
  if (services.isEmpty) return const [];

  final byMain = <PrestaMainService, List<ServiceBeaute>>{};
  final others = <ServiceBeaute>[];

  for (final service in services) {
    final main = _mainForService(service);
    if (main != null) {
      byMain.putIfAbsent(main, () => []).add(service);
    } else {
      others.add(service);
    }
  }

  final groups = <PrestataireServiceMainGroup>[
    for (final main in PrestaMainService.values)
      if (byMain[main]?.isNotEmpty ?? false)
        PrestataireServiceMainGroup(
          main: main,
          title: PrestataireServiceCatalog.label(main),
          services: byMain[main]!,
        ),
  ];

  if (others.isNotEmpty) {
    groups.add(
      PrestataireServiceMainGroup(
        title: otherGroupTitle,
        services: others,
      ),
    );
  }

  return groups;
}
