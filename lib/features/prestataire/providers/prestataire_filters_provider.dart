import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../listing/models/listing_quick_filter.dart';
import '../models/prestataires_filter_state.dart';

final prestatairesFilterProvider =
    NotifierProvider<PrestatairesFilterNotifier, PrestatairesFilterState>(
      PrestatairesFilterNotifier.new,
    );

class PrestatairesFilterNotifier extends Notifier<PrestatairesFilterState> {
  @override
  PrestatairesFilterState build() {
    return const PrestatairesFilterState();
  }

  void setQuery(String query) {
    state = state.copyWith(
      query: query,
      activeQuickFilterId: null,
      availableOnly: false,
    );
  }

  void setCategoryId(String? categoryId) {
    state = state.copyWith(
      categoryId: categoryId,
      activeQuickFilterId: null,
      availableOnly: false,
    );
  }

  void setSort(PrestatairesSort sort) {
    state = state.copyWith(
      sort: sort,
      activeQuickFilterId: null,
    );
  }

  void applyQuickFilter(ListingQuickFilter filter) {
    switch (filter.kind) {
      case ListingQuickFilterKind.all:
        state = const PrestatairesFilterState(
          activeQuickFilterId: 'all',
        );
      case ListingQuickFilterKind.availableOnly:
        state = PrestatairesFilterState(
          availableOnly: true,
          activeQuickFilterId: filter.id,
        );
      case ListingQuickFilterKind.nearby:
        state = PrestatairesFilterState(
          sort: PrestatairesSort.distance,
          activeQuickFilterId: filter.id,
        );
      case ListingQuickFilterKind.topRated:
        state = PrestatairesFilterState(
          sort: PrestatairesSort.rating,
          activeQuickFilterId: filter.id,
        );
      case ListingQuickFilterKind.styleQuery:
        state = PrestatairesFilterState(
          query: filter.query ?? '',
          activeQuickFilterId: filter.id,
        );
      case ListingQuickFilterKind.categoryId:
        state = PrestatairesFilterState(
          categoryId: filter.categoryId,
          activeQuickFilterId: filter.id,
        );
    }
  }

  void resetQuickFilters() {
    state = const PrestatairesFilterState();
  }
}

