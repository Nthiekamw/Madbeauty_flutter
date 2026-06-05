import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/offline_providers.dart';
import '../../../services/offline/offline_cache_service.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_filters.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_service.dart';

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

  /// Échec du pull-to-refresh alors qu'une liste est déjà affichée.
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
      entries: identical(entries, _unset)
          ? this.entries
          : entries as List<PrestataireCatalogEntry>,
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

  /// À appeler une fois au montage de l'écran (voir [ListingScreen]).
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
    final service = ref.read(prestataireServiceProvider);
    if (service == null) return;

    state = state.copyWith(
      loadingInitial: true,
      errorMessage: null,
      refreshError: null,
      loadMoreError: null,
    );
    await _fetchPage(service: service, offset: 0, replaceEntries: true);
  }

  Future<void> loadMore() async {
    if (!AppConfig.hasSupabase) return;
    if (state.loadingMore || state.loadingInitial || !state.hasMore) return;

    final service = ref.read(prestataireServiceProvider);
    if (service == null) return;

    state = state.copyWith(
      loadingMore: true,
      loadMoreError: null,
      refreshError: null,
    );
    await _fetchPage(
      service: service,
      offset: state.entries.length,
      replaceEntries: false,
    );
  }

  Future<void> _fetchFirstPage() async {
    final service = ref.read(prestataireServiceProvider);
    if (service == null) {
      if (!ref.mounted) return;
      state = state.copyWith(loadingInitial: false, hasMore: false);
      return;
    }
    await _fetchPage(service: service, offset: 0, replaceEntries: true);
  }

  Future<void> _fetchPage({
    required PrestataireService service,
    required int offset,
    required bool replaceEntries,
  }) async {
    final online = ref.read(isOnlineProvider);
    if (!online) {
      final cached = OfflineCacheService.instance.readListingCatalog();
      if (!ref.mounted) return;
      if (cached.entries.isEmpty) {
        state = state.copyWith(
          loadingInitial: false,
          loadingMore: false,
          errorMessage: DiscList.catalogLoadErr,
          hasMore: false,
        );
        return;
      }
      state = state.copyWith(
        loadingInitial: false,
        loadingMore: false,
        categories: cached.categories,
        entries: cached.entries,
        hasMore: false,
        errorMessage: null,
        refreshError: ShellStrings.offlineCatalogCacheOnly,
        loadMoreError: null,
      );
      return;
    }

    try {
      late final List<ServiceCategory> categories;
      late final List<PrestataireCatalogEntry> batch;

      if (replaceEntries) {
        final results = await Future.wait([
          service.getServiceCategories(),
          service.getAll(
            filters: PrestataireFilters(limit: pageSize, offset: offset),
          ),
        ]);
        categories = results[0] as List<ServiceCategory>;
        batch = results[1] as List<PrestataireCatalogEntry>;
      } else {
        categories = state.categories;
        batch = await service.getAll(
          filters: PrestataireFilters(limit: pageSize, offset: offset),
        );
      }

      if (!ref.mounted) return;

      final merged = replaceEntries ? batch : [...state.entries, ...batch];

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

      if (replaceEntries) {
        await OfflineCacheService.instance.saveListingCatalog(
          categories: categories,
          entries: merged,
        );
      }
    } catch (e, st) {
      assert(() {
        FlutterError.dumpErrorToConsole(
          FlutterErrorDetails(exception: e, stack: st),
        );
        return true;
      }());

      if (!ref.mounted) return;

      final cached = OfflineCacheService.instance.readListingCatalog();
      if (replaceEntries && cached.entries.isNotEmpty) {
        state = state.copyWith(
          loadingInitial: false,
          loadingMore: false,
          categories: cached.categories,
          entries: cached.entries,
          hasMore: false,
          errorMessage: null,
          refreshError: ShellStrings.offlineCatalogCacheOnly,
          loadMoreError: null,
        );
        return;
      }

      if (replaceEntries && state.entries.isEmpty) {
        state = state.copyWith(
          loadingInitial: false,
          loadingMore: false,
          errorMessage: DiscList.catalogLoadErr,
          refreshError: null,
          loadMoreError: null,
          hasMore: false,
        );
      } else if (replaceEntries) {
        state = state.copyWith(
          loadingInitial: false,
          loadingMore: false,
          refreshError: DiscList.refreshErr,
          loadMoreError: null,
        );
      } else {
        state = state.copyWith(
          loadingInitial: false,
          loadingMore: false,
          loadMoreError: DiscList.loadMoreErr,
          refreshError: null,
        );
      }
    }
  }
}

