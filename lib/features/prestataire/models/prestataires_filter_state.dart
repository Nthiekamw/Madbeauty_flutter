enum PrestatairesSort { rating, distance }

class PrestatairesFilterState {
  const PrestatairesFilterState({
    this.query = '',
    this.categoryId,
    this.ville,
    this.sort = PrestatairesSort.distance,
    this.availableOnly = false,
    this.favoritesOnly = false,
    this.likedOnly = false,
    this.activeQuickFilterId,
  });

  final String query;
  final String? categoryId;

  /// Filtre exact sur [PrestataireProfile.ville] (insensible à la casse).
  final String? ville;
  final PrestatairesSort sort;
  final bool availableOnly;
  final bool favoritesOnly;
  final bool likedOnly;

  /// Identifiant du filtre rapide actif ([ListingQuickFilter.id]).
  final String? activeQuickFilterId;

  bool get hasActiveFilters =>
      query.trim().isNotEmpty ||
      categoryId != null ||
      (ville != null && ville!.trim().isNotEmpty) ||
      availableOnly ||
      favoritesOnly ||
      likedOnly ||
      (activeQuickFilterId != null && activeQuickFilterId != 'all');

  PrestatairesFilterState copyWith({
    String? query,
    Object? categoryId = _unset,
    Object? ville = _unset,
    PrestatairesSort? sort,
    bool? availableOnly,
    bool? favoritesOnly,
    bool? likedOnly,
    Object? activeQuickFilterId = _unset,
  }) {
    return PrestatairesFilterState(
      query: query ?? this.query,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      ville: identical(ville, _unset) ? this.ville : ville as String?,
      sort: sort ?? this.sort,
      availableOnly: availableOnly ?? this.availableOnly,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      likedOnly: likedOnly ?? this.likedOnly,
      activeQuickFilterId: identical(activeQuickFilterId, _unset)
          ? this.activeQuickFilterId
          : activeQuickFilterId as String?,
    );
  }
}

const _unset = Object();

