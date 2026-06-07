import '../../../core/constants/prestataire/prestataire_service_catalog.dart';

/// Sélection active sur l'accueil (recherche ou inspiration).
enum HomeFeedSource { search, inspiration }

class HomeFeedSelection {
  const HomeFeedSelection({
    this.query = '',
    required this.source,
    this.mainService,
    this.allServices = false,
  });

  final String query;
  final HomeFeedSource source;

  /// Filtre par service principal (Coiffure, Manucure…).
  final PrestaMainService? mainService;

  /// Affiche tous les prestataires (puce « Toutes »).
  final bool allServices;

  /// Sélection par défaut à l'ouverture de l'accueil.
  static const defaultInspiration = HomeFeedSelection(
    source: HomeFeedSource.inspiration,
    allServices: true,
  );

  bool get showsFeedSection =>
      allServices || mainService != null || query.trim().isNotEmpty;
}
