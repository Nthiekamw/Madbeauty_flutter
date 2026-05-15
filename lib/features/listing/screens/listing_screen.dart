import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../prestataire/models/prestataires_filter_state.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';
import '../../prestataire/providers/prestataires_provider.dart';
import '../providers/client_location_provider.dart';
import '../providers/listing_catalog_provider.dart';
import '../widgets/listing_map_view.dart';
import '../widgets/listing_vertical_skeleton.dart';
import '../widgets/prestataire_catalog_list_card.dart';

enum _ListingViewMode { list, map }

/// Exploration / recherche : catalogue paginé, filtres, tri, pull-to-refresh.
class ListingScreen extends ConsumerStatefulWidget {
  const ListingScreen({super.key});

  @override
  ConsumerState<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends ConsumerState<ListingScreen> {
  final _searchController = TextEditingController();
  bool _seededFromRoute = false;
  _ListingViewMode _viewMode = _ListingViewMode.list;

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

  Widget _filtersBar(ThemeData theme, List<ServiceCategory> categories) {
    final filters = ref.watch(prestatairesFilterProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DiscList.sortLabel,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<PrestatairesSort>(
                  segments: [
                    ButtonSegment<PrestatairesSort>(
                      value: PrestatairesSort.rating,
                      label: Text(DiscList.sortRating),
                    ),
                    ButtonSegment<PrestatairesSort>(
                      value: PrestatairesSort.distance,
                      label: Text(DiscList.sortDistance),
                    ),
                  ],
                  emptySelectionAllowed: false,
                  showSelectedIcon: false,
                  selected: {filters.sort},
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) return;
                    ref
                        .read(prestatairesFilterProvider.notifier)
                        .setSort(selection.first);
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
              DiscList.svcTypeLabel,
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
                    label: Text(DiscList.chipAll),
                    selected: filters.categoryId == null,
                    onSelected: (_) {
                      ref
                          .read(prestatairesFilterProvider.notifier)
                          .setCategoryId(null);
                    },
                  ),
                ),
                ...categories.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c.nom),
                      selected: filters.categoryId == c.id,
                      onSelected: (selected) {
                        ref
                            .read(prestatairesFilterProvider.notifier)
                            .setCategoryId(selected ? c.id : null);
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

  Widget _viewModeSwitch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SegmentedButton<_ListingViewMode>(
        segments: const [
          ButtonSegment<_ListingViewMode>(
            value: _ListingViewMode.list,
            icon: Icon(Icons.list_alt_outlined),
            label: Text(DiscList.modeList),
          ),
          ButtonSegment<_ListingViewMode>(
            value: _ListingViewMode.map,
            icon: Icon(Icons.map_outlined),
            label: Text(DiscList.modeMap),
          ),
        ],
        selected: {_viewMode},
        onSelectionChanged: (selection) {
          if (selection.isEmpty) return;
          setState(() => _viewMode = selection.first);
        },
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
              DiscList.emptyCatalogTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscList.pullDownHint,
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
              DiscList.emptyFilterTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscList.emptyFilterHint,
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
              DiscList.catalogLoadErr,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(listingCatalogNotifierProvider.notifier).refresh(),
              child: const Text(DiscList.retry),
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

    return Scaffold(
      appBar: AppBar(title: Text(DiscNav.listingTitle)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: AppTextField(
                controller: _searchController,
                hint: DiscList.hintSearch,
                textInputAction: TextInputAction.search,
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(prestatairesFilterProvider.notifier)
                              .setQuery('');
                        },
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                onChanged: (value) {
                  ref.read(prestatairesFilterProvider.notifier).setQuery(value);
                },
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
              Expanded(child: _buildMainBody(theme, catalogState)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBody(ThemeData theme, ListingCatalogViewState state) {
    if (state.loadingInitial &&
        state.entries.isEmpty &&
        state.errorMessage == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filtersBar(theme, state.categories),
          _viewModeSwitch(),
          const Expanded(child: ListingVerticalSkeleton()),
        ],
      );
    }

    if (state.errorMessage != null && state.entries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filtersBar(theme, state.categories),
          _viewModeSwitch(),
          Expanded(child: _refreshableScrollable(child: _errorState(theme))),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filtersBar(theme, state.categories),
        _viewModeSwitch(),
        Expanded(child: _buildCatalogBody(theme, state)),
      ],
    );
  }

  Widget _buildCatalogBody(ThemeData theme, ListingCatalogViewState state) {
    final all = state.entries;

    if (all.isEmpty) {
      return _refreshableScrollable(child: _emptyCatalogState(theme));
    }

    final filtered = ref.watch(prestatairesFilteredProvider).value ?? const [];
    if (filtered.isEmpty) {
      return _refreshableScrollable(child: _emptyFilterState(theme));
    }

    if (_viewMode == _ListingViewMode.map) {
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ListingMapView(
              entries: filtered,
              clientLocation: clientLocation,
              locationLoading: locationAsync.isLoading,
            ),
          ),
        ),
        if (showFooter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _loadMoreFooter(theme, state),
          ),
      ],
    );
  }
}
