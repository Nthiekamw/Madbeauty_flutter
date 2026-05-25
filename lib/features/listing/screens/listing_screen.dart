import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery_empty_state.dart';
import '../../../shared/widgets/discovery_screen_header.dart';
import '../../../shared/widgets/discovery_search_card.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';
import '../../prestataire/providers/prestataires_provider.dart';
import '../providers/client_location_provider.dart';
import '../providers/listing_catalog_provider.dart';
import '../widgets/listing_filters_panel.dart';
import '../widgets/listing_map_view.dart';
import '../widgets/listing_vertical_skeleton.dart';
import '../widgets/prestataire_catalog_list_card.dart';

/// Exploration / recherche : catalogue paginé, filtres, tri, pull-to-refresh.
class ListingScreen extends ConsumerStatefulWidget {
  const ListingScreen({super.key});

  @override
  ConsumerState<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends ConsumerState<ListingScreen> {
  final _searchController = TextEditingController();
  bool _seededFromRoute = false;
  ListingViewMode _viewMode = ListingViewMode.list;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(listingCatalogNotifierProvider.notifier).loadInitialIfNeeded();
    });
  }

  void _onSearchTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
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

  Widget _searchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: DiscoverySearchCard(
        controller: _searchController,
        hint: DiscList.hintSearch,
        onChanged: (value) {
          ref.read(prestatairesFilterProvider.notifier).setQuery(value);
        },
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(
                  context,
                ).deleteButtonTooltip,
                onPressed: () {
                  _searchController.clear();
                  ref.read(prestatairesFilterProvider.notifier).setQuery('');
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  Widget _resultsCountBar(ThemeData theme, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catalogState = ref.watch(listingCatalogNotifierProvider);

    return DiscoveryBrandScaffold(
      backgroundColor: const Color(0xFFF5EFE6),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DiscoveryScreenHeader(
            title: DiscNav.searchTitle,
            subtitle: DiscList.searchSubtitle,
            whiteBar: true,
          ),
          _searchBar(theme),
          if (!AppConfig.hasSupabase)
            Expanded(
              child: DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: ShellStrings.supabaseMissingTitle,
                body: ShellStrings.supabaseMissingBody,
                iconColor: theme.colorScheme.error,
              ),
            )
          else
            Expanded(child: _buildMainBody(theme, catalogState)),
        ],
      ),
    );
  }

  Widget _buildMainBody(ThemeData theme, ListingCatalogViewState state) {
    final filtersPanel = ListingFiltersPanel(
      categories: state.categories,
      viewMode: _viewMode,
      onViewModeChanged: (mode) => setState(() => _viewMode = mode),
    );

    if (state.loadingInitial &&
        state.entries.isEmpty &&
        state.errorMessage == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filtersPanel,
          const Expanded(child: ListingVerticalSkeleton()),
        ],
      );
    }

    if (state.errorMessage != null && state.entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          filtersPanel,
          Expanded(
            child: _refreshableScrollable(
              child: DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: DiscList.catalogLoadErr,
                body: DiscList.pullDownHint,
                iconColor: theme.colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: () => ref
                    .read(listingCatalogNotifierProvider.notifier)
                    .refresh(),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        filtersPanel,
        Expanded(child: _buildCatalogBody(theme, state)),
      ],
    );
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

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _resultsCountBar(theme, filtered.length),
          for (var i = 0; i < filtered.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            PrestataireCatalogListCard(entry: filtered[i]),
          ],
          if (showFooter) _loadMoreFooter(theme, state),
        ],
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _resultsCountBar(theme, filtered.length),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _loadMoreFooter(theme, state),
          ),
      ],
    );
  }
}
