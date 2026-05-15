enum PrestatairesSort { rating, distance }

class PrestatairesFilterState {
  const PrestatairesFilterState({
    this.query = '',
    this.categoryId,
    this.sort = PrestatairesSort.distance,
  });

  final String query;
  final String? categoryId;
  final PrestatairesSort sort;

  PrestatairesFilterState copyWith({
    String? query,
    Object? categoryId = _unset,
    PrestatairesSort? sort,
  }) {
    return PrestatairesFilterState(
      query: query ?? this.query,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      sort: sort ?? this.sort,
    );
  }
}

const _unset = Object();
