enum PrestatairesSort { rating, distance }

class PrestatairesFilterState {
  const PrestatairesFilterState({
    this.query = '',
    this.categoryId,
    this.sort = PrestatairesSort.distance,
    this.availableOnly = false,
    this.activeQuickFilterId,
  });

  final String query;
  final String? categoryId;
  final PrestatairesSort sort;
  final bool availableOnly;

  /// Identifiant du filtre rapide actif ([ListingQuickFilter.id]).
  final String? activeQuickFilterId;

  PrestatairesFilterState copyWith({
    String? query,
    Object? categoryId = _unset,
    PrestatairesSort? sort,
    bool? availableOnly,
    Object? activeQuickFilterId = _unset,
  }) {
    return PrestatairesFilterState(
      query: query ?? this.query,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      sort: sort ?? this.sort,
      availableOnly: availableOnly ?? this.availableOnly,
      activeQuickFilterId: identical(activeQuickFilterId, _unset)
          ? this.activeQuickFilterId
          : activeQuickFilterId as String?,
    );
  }
}

const _unset = Object();
