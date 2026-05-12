import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/listing_sort.dart';
import '../providers/listing_catalog_provider.dart';
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
  ListingSort _sort = ListingSort.distance;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(listingCatalogNotifierProvider.notifier).loadInitialIfNeeded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seededFromRoute) return;
    final q = GoRouterState.of(context).uri.queryParameters['q']?.trim();
    if (q != null && q.isNotEmpty) {
      _searchController.text = q;
    }
    _seededFromRoute = true;
  }

  Future<void> _onRefresh() async {
    await ref.read(listingCatalogNotifierProvider.notifier).refresh();
  }

  void _sortEntries(List<PrestataireCatalogEntry> list, ListingSort sort) {
    switch (sort) {
      case ListingSort.rating:
        list.sort((a, b) {
          final na = a.profile.noteMoyenne;
          final nb = b.profile.noteMoyenne;
          if (na != null && nb != null && na != nb) {
            return nb.compareTo(na);
          }
          if (na != null && nb == null) return -1;
          if (na == null && nb != null) return 1;
          return b.profile.createdAt.compareTo(a.profile.createdAt);
        });
      case ListingSort.distance:
        list.sort((a, b) {
          final da = a.sortDistanceKm;
          final db = b.sortDistanceKm;
          final aInf = da.isInfinite;
          final bInf = db.isInfinite;
          if (aInf && bInf) return 0;
          if (aInf) return 1;
          if (bInf) return -1;
          return da.compareTo(db);
        });
    }
  }

  List<PrestataireCatalogEntry> _filteredAndSorted(
    List<PrestataireCatalogEntry> all,
  ) {
    final list = all
        .where((e) => e.matchesSearch(_searchController.text))
        .where((e) => e.matchesCategoryFilter(_selectedCategoryId))
        .toList();
    _sortEntries(list, _sort);
    return list;
  }

  Widget _filtersBar(
    ThemeData theme,
    List<ServiceCategory> categories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DiscoveryStrings.listingSortLabel,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<ListingSort>(
                  segments: [
                    ButtonSegment<ListingSort>(
                      value: ListingSort.rating,
                      label: Text(DiscoveryStrings.listingSortRating),
                    ),
                    ButtonSegment<ListingSort>(
                      value: ListingSort.distance,
                      label: Text(DiscoveryStrings.listingSortDistance),
                    ),
                  ],
                  emptySelectionAllowed: false,
                  showSelectedIcon: false,
                  selected: {_sort},
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) return;
                    setState(() => _sort = selection.first);
                  },
                ),
              ),
            ],
          ),
        ),
        if (categories.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              DiscoveryStrings.listingServicesLabel,
              style: theme.textTheme.labelLarge,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(DiscoveryStrings.listingChipAll),
                    selected: _selectedCategoryId == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategoryId = null),
                  ),
                ),
                ...categories.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c.nom),
                      selected: _selectedCategoryId == c.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? c.id : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _refreshableScrollable({
    required Widget child,
  }) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _emptyCatalogState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              DiscoveryStrings.listingCatalogEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscoveryStrings.listingPullToRefreshHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyFilterState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              DiscoveryStrings.listingFilterEmpty,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscoveryStrings.listingFilterEmptyHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              DiscoveryStrings.listingCatalogLoadError,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(listingCatalogNotifierProvider.notifier).refresh(),
              child: const Text(DiscoveryStrings.listingRetry),
            ),
          ],
        ),
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
                      child: Text(DiscoveryStrings.listingSeeMore),
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
                child: Text(DiscoveryStrings.listingRetry),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(DiscoveryStrings.screenListing),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: AppTextField(
                controller: _searchController,
                hint: DiscoveryStrings.listingSearchHint,
                textInputAction: TextInputAction.search,
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(context)
                            .deleteButtonTooltip,
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (!AppConfig.hasSupabase)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    ShellStrings.supabaseMissingBody,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              )
            else
              Expanded(
                child: _buildMainBody(theme, catalogState),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBody(ThemeData theme, ListingCatalogViewState state) {
    if (state.loadingInitial && state.entries.isEmpty && state.errorMessage == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filtersBar(theme, state.categories),
          const Expanded(child: ListingVerticalSkeleton()),
        ],
      );
    }

    if (state.errorMessage != null && state.entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filtersBar(theme, state.categories),
          Expanded(
            child: _refreshableScrollable(
              child: _errorState(theme),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filtersBar(theme, state.categories),
        Expanded(
          child: _buildCatalogBody(theme, state),
        ),
      ],
    );
  }

  Widget _buildCatalogBody(ThemeData theme, ListingCatalogViewState state) {
    final all = state.entries;

    if (all.isEmpty) {
      return _refreshableScrollable(
        child: _emptyCatalogState(theme),
      );
    }

    final filtered = _filteredAndSorted(all);
    if (filtered.isEmpty) {
      return _refreshableScrollable(
        child: _emptyFilterState(theme),
      );
    }

    final showFooter =
        state.hasMore || state.loadMoreError != null || state.refreshError != null;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          for (var i = 0; i < filtered.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            PrestataireCatalogListCard(entry: filtered[i]),
          ],
          if (showFooter) _loadMoreFooter(theme, state),
        ],
      ),
    );
  }
}
