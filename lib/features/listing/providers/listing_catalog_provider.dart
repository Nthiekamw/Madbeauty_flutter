import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../services/supabase/prestataire_catalog_repository.dart';
import '../../../services/supabase/prestataire_catalog_providers.dart';

class _Unset {
  const _Unset();
}

const _unset = _Unset();

/// État du listing (catégories + catalogue paginé).
@immutable
class ListingCatalogViewState {
  const ListingCatalogViewState({
    required this.categories,
    required this.entries,
    required this.loadingInitial,
    required this.loadingMore,
    this.errorMessage,
    this.refreshError,
    this.loadMoreError,
    required this.hasMore,
  });

  final List<ServiceCategory> categories;
  final List<PrestataireCatalogEntry> entries;
  final bool loadingInitial;
  final bool loadingMore;

  /// Erreur du premier chargement : pas de lignes affichées.
  final String? errorMessage;

  /// Échec du pull-to-refresh alors qu’une liste est déjà affichée.
  final String? refreshError;

  /// Erreur sur « Voir plus » : la liste déjà chargée reste visible.
  final String? loadMoreError;

  final bool hasMore;

  static const ListingCatalogViewState initial = ListingCatalogViewState(
    categories: [],
    entries: [],
    loadingInitial: true,
    loadingMore: false,
    hasMore: true,
  );

  ListingCatalogViewState copyWith({
    Object? categories = _unset,
    Object? entries = _unset,
    bool? loadingInitial,
    bool? loadingMore,
    Object? errorMessage = _unset,
    Object? refreshError = _unset,
    Object? loadMoreError = _unset,
    bool? hasMore,
  }) {
    return ListingCatalogViewState(
      categories: identical(categories, _unset)
          ? this.categories
          : categories as List<ServiceCategory>,
      entries:
          identical(entries, _unset) ? this.entries : entries as List<PrestataireCatalogEntry>,
      loadingInitial: loadingInitial ?? this.loadingInitial,
      loadingMore: loadingMore ?? this.loadingMore,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      refreshError: identical(refreshError, _unset)
          ? this.refreshError
          : refreshError as String?,
      loadMoreError: identical(loadMoreError, _unset)
          ? this.loadMoreError
          : loadMoreError as String?,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Catalogue listing : 10 prestataires par page, « Voir plus » pour la suite.
final listingCatalogNotifierProvider =
    NotifierProvider<ListingCatalogNotifier, ListingCatalogViewState>(
  ListingCatalogNotifier.new,
);

class ListingCatalogNotifier extends Notifier<ListingCatalogViewState> {
  static const int pageSize = 10;

  bool _started = false;

  @override
  ListingCatalogViewState build() {
    return ListingCatalogViewState.initial;
  }

  /// À appeler une fois au montage de l’écran (voir [ListingScreen]).
  void loadInitialIfNeeded() {
    if (_started) return;
    _started = true;
    if (!AppConfig.hasSupabase) {
    state = state.copyWith(
      loadingInitial: false,
      categories: const [],
      entries: const [],
      hasMore: false,
      errorMessage: null,
      refreshError: null,
      loadMoreError: null,
    );
      return;
    }
    unawaited(_fetchFirstPage());
  }

  Future<void> refresh() async {
    if (!AppConfig.hasSupabase) return;
    final repo = ref.read(prestataireCatalogRepositoryProvider);
    if (repo == null) return;

    state = state.copyWith(
      loadingInitial: true,
      errorMessage: null,
      refreshError: null,
      loadMoreError: null,
    );
    await _fetchPage(repo: repo, offset: 0, replaceEntries: true);
  }

  Future<void> loadMore() async {
    if (!AppConfig.hasSupabase) return;
    if (state.loadingMore || state.loadingInitial || !state.hasMore) return;

    final repo = ref.read(prestataireCatalogRepositoryProvider);
    if (repo == null) return;

    state = state.copyWith(loadingMore: true, loadMoreError: null, refreshError: null);
    await _fetchPage(
      repo: repo,
      offset: state.entries.length,
      replaceEntries: false,
    );
  }

  Future<void> _fetchFirstPage() async {
    final repo = ref.read(prestataireCatalogRepositoryProvider);
    if (repo == null) {
      if (!ref.mounted) return;
      state = state.copyWith(loadingInitial: false, hasMore: false);
      return;
    }
    await _fetchPage(repo: repo, offset: 0, replaceEntries: true);
  }

  Future<void> _fetchPage({
    required PrestataireCatalogRepository repo,
    required int offset,
    required bool replaceEntries,
  }) async {
    try {
      late final List<ServiceCategory> categories;
      late final List<PrestataireCatalogEntry> batch;

      if (replaceEntries) {
        final results = await Future.wait([
          repo.fetchServiceCategories(),
          repo.fetchCatalogEntries(limit: pageSize, offset: offset),
        ]);
        categories = results[0] as List<ServiceCategory>;
        batch = results[1] as List<PrestataireCatalogEntry>;
      } else {
        categories = state.categories;
        batch = await repo.fetchCatalogEntries(limit: pageSize, offset: offset);
      }

      if (!ref.mounted) return;

      final merged = replaceEntries
          ? batch
          : [...state.entries, ...batch];

      state = state.copyWith(
        loadingInitial: false,
        loadingMore: false,
        categories: categories,
        entries: merged,
        hasMore: batch.length >= pageSize,
        errorMessage: null,
        refreshError: null,
        loadMoreError: null,
      );
    } catch (e, st) {
      assert(() {
        FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: st),
        );
        return true;
      }());

      if (!ref.mounted) return;

      if (replaceEntries && state.entries.isEmpty) {
        state = state.copyWith(
          loadingInitial: false,
          loadingMore: false,
          errorMessage: DiscoveryStrings.listingCatalogLoadError,
          refreshError: null,
          loadMoreError: null,
          hasMore: false,
        );
      } else if (replaceEntries) {
        state = state.copyWith(
          loadingInitial: false,
          loadingMore: false,
          refreshError: DiscoveryStrings.listingRefreshError,
          loadMoreError: null,
        );
      } else {
        state = state.copyWith(
          loadingInitial: false,
          loadingMore: false,
          loadMoreError: DiscoveryStrings.listingLoadMoreError,
          refreshError: null,
        );
      }
    }
  }
}
