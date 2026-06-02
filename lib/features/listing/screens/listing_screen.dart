import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../client/widgets/workspace/client_workspace_search_row.dart';
import '../../client/widgets/workspace/client_workspace_shell.dart';
import '../models/listing_catalog_layout.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';
import '../../prestataire/providers/prestataires_provider.dart';
import '../providers/client_location_provider.dart';
import '../providers/listing_catalog_provider.dart';
import '../widgets/listing_category_strip.dart';
import '../widgets/listing_filters_panel.dart';
import '../widgets/listing_promo_banner.dart';
import '../widgets/listing_quick_filters_strip.dart';
import '../widgets/listing_map_view.dart';
import '../widgets/listing_vertical_skeleton.dart';
import '../widgets/listing_prestataires_scroll_view.dart';
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
  ListingViewMode _viewMode = ListingViewMode.list;
  ListingCatalogLayout _catalogLayout = ListingCatalogLayout.expanded;
  // Liste type maquette par défaut (cartes horizontales étendues).

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
    await ref.read(listingCatalogNotifierProvider.notifier).refresh();
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

  Widget _resultsCountBar(ThemeData theme, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Text(
        DiscList.resultsCount(count),
        style: theme.textTheme.labelLarge?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _refreshableScrollable({required Widget child}) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
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
    return Material(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                child: Text(DiscList.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFiltersSheet(ListingCatalogViewState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: ListingFiltersPanel(
            categories: state.categories,
            viewMode: _viewMode,
            onViewModeChanged: (mode) {
              setState(() => _viewMode = mode);
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }

  Widget _discoveryScrollHeader(ListingCatalogViewState state, int count) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListingCategoryStrip(categories: state.categories),
        const ListingPromoBanner(),
        ListingQuickFiltersStrip(
          outlinedStyle: true,
          showTitle: false,
          onStyleQuerySelected: (query) {
            if (_searchController.text != query) {
              _searchController.text = query;
            }
            _onSearchChanged(query);
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DiscClientWorkspace.sectionAvailableToday,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                DiscClientWorkspace.seeAll,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (count > 0) _resultsCountBar(theme, count),
      ],
    );
  }

  Widget _filtersPanel(ListingCatalogViewState state) {
    return ListingFiltersPanel(
      categories: state.categories,
      viewMode: _viewMode,
      onViewModeChanged: (mode) => setState(() => _viewMode = mode),
    );
  }

  /// Panneau filtres compact + catalogue (priorité à la zone résultats).
  Widget _catalogColumn({
    required ListingCatalogViewState state,
    required Widget child,
  }) {
    final layout = DiscoveryResponsive.of(context);
    final screenH = MediaQuery.sizeOf(context).height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: layout.listingFiltersMaxHeight(
              screenH,
              expanded: true,
            ),
          ),
          child: SingleChildScrollView(
            child: _filtersPanel(state),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalogState = ref.watch(listingCatalogNotifierProvider);

    if (!AppConfig.hasSupabase) {
      return DiscoveryBrandScaffold(
        body: ClientWorkspaceShell(
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
      );
    }

    return DiscoveryBrandScaffold(
      body: ClientWorkspaceShell(
        top: ClientWorkspaceSearchRow(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onClear: _clearSearch,
          onFilterTap: () => _openFiltersSheet(catalogState),
          onSubmitted: _onSearchChanged,
        ),
        child: _buildMainBody(theme, catalogState),
      ),
    );
  }

  Widget _buildMainBody(ThemeData theme, ListingCatalogViewState state) {
    if (state.loadingInitial &&
        state.entries.isEmpty &&
        state.errorMessage == null) {
      return const Center(child: ListingVerticalSkeleton());
    }

    if (state.errorMessage != null && state.entries.isEmpty) {
      return _refreshableScrollable(
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
    final all = state.entries;

    if (all.isEmpty) {
      return _refreshableScrollable(
        child: DiscoveryEmptyState(
          icon: Icons.storefront_outlined,
          title: DiscList.emptyCatalogTitle,
          body: DiscList.pullDownHint,
        ),
      );
    }

    final filtered = ref.watch(prestatairesFilteredProvider).value ?? const [];
    if (filtered.isEmpty) {
      return _refreshableScrollable(
        child: DiscoveryEmptyState(
          icon: Icons.search_off_rounded,
          title: DiscList.emptyFilterTitle,
          body: DiscList.emptyFilterHint,
        ),
      );
    }

    if (_viewMode == ListingViewMode.map) {
      return _buildMapBody(theme, state, filtered);
    }

    final showFooter =
        state.hasMore ||
        state.loadMoreError != null ||
        state.refreshError != null;

    return ListingPrestatairesScrollView(
      controller: _listScrollController,
      entries: filtered,
      layout: _catalogLayout,
      onRefresh: _onRefresh,
      header: _discoveryScrollHeader(state, filtered.length),
      footer: showFooter ? _loadMoreFooter(theme, state) : null,
    );
  }

  Widget _buildMapBody(
    ThemeData theme,
    ListingCatalogViewState state,
    List<PrestataireCatalogEntry> filtered,
  ) {
    final locationAsync = ref.watch(clientLocationProvider);
    final clientLocation = switch (locationAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final showFooter =
        state.hasMore ||
        state.loadMoreError != null ||
        state.refreshError != null;

    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 4),
          child: _resultsCountBar(theme, filtered.length),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12),
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
                child: ListingMapView(
                  entries: filtered,
                  clientLocation: clientLocation,
                  locationLoading: locationAsync.isLoading,
                ),
              ),
            ),
          ),
        ),
        if (showFooter)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: _loadMoreFooter(theme, state),
          ),
      ],
    );
  }
}
