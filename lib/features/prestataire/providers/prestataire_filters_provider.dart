import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    state = state.copyWith(query: query);
  }

  void setCategoryId(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setSort(PrestatairesSort sort) {
    state = state.copyWith(sort: sort);
  }
}
