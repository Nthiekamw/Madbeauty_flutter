import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/discovery/content/discovery_inline_error_banner.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../client/widgets/workspace/client_workspace_search_row.dart';
import '../../client/widgets/workspace/client_workspace_header.dart';
import '../../client/widgets/workspace/client_workspace_shell.dart';
import '../models/listing_quick_filter.dart';
import '../../prestataire/providers/catalog/prestataire_filters_provider.dart';
import '../../prestataire/providers/catalog/prestataires_provider.dart';
import '../providers/client_location_provider.dart';
import '../providers/listing_catalog_provider.dart';
import '../../../router/navigation_extensions.dart';
import '../providers/listing_map_catalog_provider.dart';
import '../providers/listing_view_preferences_provider.dart';
import '../widgets/filters/listing_active_filters_bar.dart';
import '../widgets/filters/listing_filters_panel.dart';
import '../widgets/filters/listing_filters_sheet.dart';
import '../widgets/header/listing_main_services_strip.dart';
import '../widgets/content/listing_promo_banner.dart';
import '../widgets/filters/listing_cities_strip.dart';
import '../widgets/filters/listing_quick_filters_strip.dart';
import '../widgets/header/listing_results_header.dart';
import '../widgets/content/listing_map_view.dart';
import '../widgets/content/listing_vertical_skeleton.dart';
import '../widgets/content/listing_prestataires_scroll_view.dart';
import '../../../shared/layout/adaptive_safe_area.dart';
import '../../../shared/layout/discovery_responsive.dart';

/// Exploration / recherche : catalogue paginé, filtres, tri, pull-to-refresh.
class ListingScreen extends ConsumerStatefulWidget {
  const ListingScreen({super.key});

  @override
  ConsumerState<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends ConsumerState<ListingScreen> {
  final _searchController = TextEditingController();
  final _listScrollController = ScrollController();
  bool _seededFromRoute = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    _listScrollController.addListener(_onListScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(listingCatalogNotifierProvider.notifier).loadInitialIfNeeded();
    });
  }

  void _onListScroll() {
    if (!_listScrollController.hasClients) return;
    final position = _listScrollController.position;
    if (position.pixels < position.maxScrollExtent - 420) return;

    final state = ref.read(listingCatalogNotifierProvider);
    if (!state.hasMore || state.loadingMore || state.loadingInitial) return;

    ref.read(listingCatalogNotifierProvider.notifier).loadMore();
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _listScrollController.removeListener(_onListScroll);
    _searchController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seededFromRoute) return;
    final q = GoRouterState.of(context).uri.queryParameters['q']?.trim();
    final initialQuery = q == null || q.isEmpty ? '' : q;
    _seededFromRoute = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchController.text = initialQuery;
      ref.read(prestatairesFilterProvider.notifier).setQuery(initialQuery);
    });
  }

  Future<void> _onRefresh() async {
    ref.invalidate(listingMapCatalogProvider);
    await ref.read(listingCatalogNotifierProvider.notifier).refresh();
  }

  void _clearSearchFieldOnly() {
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      setState(() {});
    }
  }

  void _onSearchChanged(String value) {
    ref.read(prestatairesFilterProvider.notifier).setQuery(value);
    if (value.trim().isEmpty &&
        ref.read(prestatairesFilterProvider).activeQuickFilterId != null) {
      ref.read(prestatairesFilterProvider.notifier).resetQuickFilters();
    }
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(prestatairesFilterProvider.notifier).setQuery('');
    setState(() {});
  }

  Widget _refreshableScrollable({
    required Widget child,
    ListingCatalogViewState? state,
  }) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (state != null)
            SliverToBoxAdapter(child: _catalogScrollHeader(state)),
          SliverFillRemaining(hasScrollBody: false, child: child),
        ],
      ),
    );
  }

  Widget _loadMoreFooter(ThemeData theme, ListingCatalogViewState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.refreshError != null) ...[
            _inlineErrorBanner(
              theme,
              message: state.refreshError!,
              onRetry: () =>
                  ref.read(listingCatalogNotifierProvider.notifier).refresh(),
            ),
            const SizedBox(height: 12),
          ],
          if (state.loadMoreError != null) ...[
            _inlineErrorBanner(
              theme,
              message: state.loadMoreError!,
              onRetry: () =>
                  ref.read(listingCatalogNotifierProvider.notifier).loadMore(),
            ),
            const SizedBox(height: 12),
          ],
          if (state.hasMore)
            Center(
              child: state.loadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : FilledButton.tonal(
                      onPressed: state.loadingInitial
                          ? null
                          : () => ref
                                .read(listingCatalogNotifierProvider.notifier)
                                .loadMore(),
                      child: Text(DiscList.seeMore),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _inlineErrorBanner(
    ThemeData theme, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return DiscoveryInlineErrorBanner(
      message: message,
      onRetry: onRetry,
    );
  }

  void _openFiltersSheet(ListingCatalogViewState state) {
    showListingFiltersSheet(
      context,
      categories: state.categories,
    );
  }

  void _openAllPrestataires() {
    context.pushAllPrestataires();
  }

  Widget _resultsHeader(ListingCatalogViewState state) {
    final filters = ref.watch(prestatairesFilterProvider);
    final filteredAsync = ref.watch(prestatairesFilteredProvider);
    final count = filteredAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => state.entries.length,
    );
    final title = filters.availableOnly
        ? DiscClientWorkspace.sectionAvailableToday
        : filters.hasActiveFilters
            ? DiscList.resultsFilteredTitle
            : DiscList.resultsDiscoverTitle;

    return ListingResultsHeader(
      count: count,
      title: title,
      secondaryActionLabel: DiscClientWorkspace.seeAll,
      onSecondaryAction: _openAllPrestataires,
    );
  }

  Widget _catalogChrome(ListingCatalogViewState state) {
    if (state.loadingInitial && state.entries.isEmpty) {
      return const SizedBox.shrink();
    }

    if (state.entries.isNotEmpty) {
      return _resultsHeader(state);
    }
    return const SizedBox.shrink();
  }

  Widget _searchTopFixed() {
    final mapMode =
        ref.watch(listingViewPreferencesProvider).viewMode ==
        ListingViewMode.map;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClientWorkspaceSearchRow(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onClear: _clearSearch,
          onFilterTap: () => _openFiltersSheet(
            ref.read(listingCatalogNotifierProvider),
          ),
          onSubmitted: _onSearchChanged,
          filtersActive:
              ref.watch(prestatairesFilterProvider).hasActiveFilters,
          compact: true,
        ),
        if (!mapMode) ...[
          const ListingMainServicesStrip(),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 6),
        const ListingCitiesStrip(outlined: true),
        const SizedBox(height: 4),
      ],
    );
  }

  /// En-tête allégé au-dessus de la carte (sans bannière promo).
  Widget _catalogMapHeader(ListingCatalogViewState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        ListingQuickFiltersStrip(
          showTitle: false,
          outlined: true,
          filters: ListingQuickFilter.catalogTop,
          onClearSearchField: _clearSearchFieldOnly,
          onStyleQuerySelected: (query) {
            if (_searchController.text != query) {
              _searchController.text = query;
            }
            if (query.trim().isNotEmpty) {
              _onSearchChanged(query);
            } else {
              setState(() {});
            }
          },
        ),
        ListingActiveFiltersBar(
          categories: state.categories,
          onClearSearch: _clearSearch,
        ),
        _catalogChrome(state),
      ],
    );
  }

  Widget _catalogScrollHeader(ListingCatalogViewState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ListingPromoBanner(),
        const SizedBox(height: 12),
        ListingQuickFiltersStrip(
          showTitle: false,
          outlined: true,
          filters: ListingQuickFilter.catalogTop,
          onClearSearchField: _clearSearchFieldOnly,
          onStyleQuerySelected: (query) {
            if (_searchController.text != query) {
              _searchController.text = query;
            }
            if (query.trim().isNotEmpty) {
              _onSearchChanged(query);
            } else {
              setState(() {});
            }
          },
        ),
        ListingActiveFiltersBar(
          categories: state.categories,
          onClearSearch: _clearSearch,
        ),
        _catalogChrome(state),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalogState = ref.watch(listingCatalogNotifierProvider);

    ref.listen<ListingCatalogViewState>(listingCatalogNotifierProvider, (
      _,
      next,
    ) {
      if (!mounted) return;
      if (next.loadingInitial || next.entries.isEmpty) return;
      final filtered = ref.read(prestatairesFilteredProvider).value;
      if (filtered == null || filtered.isNotEmpty) return;
      final filters = ref.read(prestatairesFilterProvider);
      if (!filters.hasActiveFilters) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(prestatairesFilterProvider.notifier).resetQuickFilters();
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
        }
      });
    });

    if (!AppConfig.hasSupabase) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: AdaptiveSafeArea(
        child: ClientWorkspaceShell(
          title: ShellStrings.navClientSearch,
          subtitle: DiscClientWorkspace.searchSubtitle,
            top: ClientWorkspaceSearchRow(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),
            child: DiscoveryEmptyState(
              icon: Icons.cloud_off_outlined,
              title: ShellStrings.supabaseMissingTitle,
              body: ShellStrings.supabaseMissingBody,
              iconColor: theme.colorScheme.error,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AdaptiveSafeArea(
        child: ClientWorkspaceShell(
            title: ShellStrings.navClientSearch,
            subtitle: DiscClientWorkspace.searchSubtitle,
            panelOverlap: -8,
            header: const ClientWorkspaceHeader(
              subtitle: DiscClientWorkspace.searchSubtitle,
              compact: true,
            ),
          top: _searchTopFixed(),
          child: _buildMainBody(theme, catalogState),
        ),
      ),
    );
  }

  Widget _buildMainBody(ThemeData theme, ListingCatalogViewState state) {
    if (state.loadingInitial &&
        state.entries.isEmpty &&
        state.errorMessage == null) {
      return const ListingVerticalSkeleton();
    }

    if (state.errorMessage != null && state.entries.isEmpty) {
      return _refreshableScrollable(
        state: state,
        child: DiscoveryEmptyState(
          icon: Icons.cloud_off_outlined,
          title: DiscList.catalogLoadErr,
          body: DiscList.pullDownHint,
          iconColor: theme.colorScheme.error,
          actionLabel: DiscList.retry,
          onAction: () =>
              ref.read(listingCatalogNotifierProvider.notifier).refresh(),
        ),
      );
    }

    return _buildCatalogBody(theme, state);
  }

  Widget _buildCatalogBody(ThemeData theme, ListingCatalogViewState state) {
    final prefs = ref.watch(listingViewPreferencesProvider);
    final all = state.entries;

    if (all.isEmpty) {
      return _refreshableScrollable(
        state: state,
        child: DiscoveryEmptyState(
          icon: Icons.storefront_outlined,
          title: DiscList.emptyCatalogTitle,
          body: DiscList.pullDownHint,
          actionLabel: DiscList.retry,
          onAction: () =>
              ref.read(listingCatalogNotifierProvider.notifier).refresh(),
        ),
      );
    }

    final filteredAsync = ref.watch(prestatairesFilteredProvider);

    return filteredAsync.when(
      loading: () => const ListingVerticalSkeleton(),
      error: (_, __) => _refreshableScrollable(
        state: state,
        child: DiscoveryEmptyState(
          icon: Icons.cloud_off_outlined,
          title: DiscList.catalogLoadErr,
          body: DiscList.pullDownHint,
          iconColor: theme.colorScheme.error,
          actionLabel: DiscList.retry,
          onAction: () =>
              ref.read(listingCatalogNotifierProvider.notifier).refresh(),
        ),
      ),
      data: (filtered) {
        if (filtered.isEmpty) {
          return _refreshableScrollable(
            state: state,
            child: DiscoveryEmptyState(
              icon: Icons.search_off_rounded,
              title: DiscList.emptyFilterTitle,
              body: DiscList.emptyFilterHint,
              actionLabel: DiscList.quickFiltersReset,
              onAction: () {
                ref.read(prestatairesFilterProvider.notifier).resetQuickFilters();
                _clearSearch();
              },
            ),
          );
        }

        if (prefs.viewMode == ListingViewMode.map) {
          return _buildMapBody(theme, state, filtered);
        }

        final showFooter =
            state.hasMore ||
            state.loadMoreError != null ||
            state.refreshError != null;

        return ListingPrestatairesScrollView(
          controller: _listScrollController,
          entries: filtered,
          layout: prefs.catalogLayout,
          onRefresh: _onRefresh,
          header: _catalogScrollHeader(state),
          footer: showFooter ? _loadMoreFooter(theme, state) : null,
        );
      },
    );
  }

  Widget _buildMapBody(
    ThemeData theme,
    ListingCatalogViewState state,
    List<PrestataireCatalogEntry> filtered,
  ) {
    final mapEntriesAsync = ref.watch(listingMapCatalogProvider);
    final locationAsync = ref.watch(clientLocationProvider);
    final clientLocation = switch (locationAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return mapEntriesAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 8),
        child: const ListingVerticalSkeleton(),
      ),
      error: (_, __) => Padding(
        padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 8),
        child: DiscoveryInlineErrorBanner(
          message: state.errorMessage ?? DiscList.catalogLoadErr,
          onRetry: () {
            ref.invalidate(listingMapCatalogProvider);
            ref.read(listingCatalogNotifierProvider.notifier).refresh();
          },
        ),
      ),
      data: (mapEntries) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: DiscoveryStyles.cardBorderRadius,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.14),
                    ),
                    boxShadow: theme.brightness == Brightness.light
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.06,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: DiscoveryStyles.cardBorderRadius,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ListingMapView(
                          entries: mapEntries,
                          clientLocation: clientLocation,
                          locationLoading: locationAsync.isLoading,
                          borderRadius: BorderRadius.zero,
                          overlayPadding:
                              const EdgeInsets.fromLTRB(12, 128, 12, 12),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          right: 8,
                          child: Material(
                            elevation: 2,
                            shadowColor: Colors.black26,
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.94,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            child: _catalogMapHeader(state),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

