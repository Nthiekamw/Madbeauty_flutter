import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../providers/discovery_origin_provider.dart';
import '../providers/listing_catalog_provider.dart';
import '../widgets/content/listing_vertical_skeleton.dart';
import '../widgets/catalog/prestataire_catalog_list_card.dart';

/// Catalogue complet de tous les prestataires (depuis « Voir tout »).
class AllPrestatairesScreen extends ConsumerStatefulWidget {
  const AllPrestatairesScreen({super.key});

  @override
  ConsumerState<AllPrestatairesScreen> createState() =>
      _AllPrestatairesScreenState();
}

class _AllPrestatairesScreenState extends ConsumerState<AllPrestatairesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(listingCatalogNotifierProvider.notifier).loadInitialIfNeeded();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 420) return;

    final state = ref.read(listingCatalogNotifierProvider);
    if (!state.hasMore || state.loadingMore || state.loadingInitial) return;
    ref.read(listingCatalogNotifierProvider.notifier).loadMore();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(listingCatalogNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(listingCatalogNotifierProvider);
    final origin = ref.watch(discoveryOriginProvider);
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return DiscoveryBrandScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(onBack: () => context.pop()),
          Expanded(
            child: !AppConfig.hasSupabase
                ? Center(
                    child: Text(
                      ShellStrings.supabaseMissingBody,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : state.loadingInitial && state.entries.isEmpty
                    ? const Center(child: ListingVerticalSkeleton())
                    : state.errorMessage != null && state.entries.isEmpty
                        ? Center(
                            child: DiscoveryEmptyState(
                              icon: Icons.cloud_off_outlined,
                              title: DiscList.catalogLoadErr,
                              body: DiscList.pullDownHint,
                              actionLabel: DiscList.retry,
                              onAction: _onRefresh,
                            ),
                          )
                        : state.entries.isEmpty
                            ? Center(
                                child: DiscoveryEmptyState(
                                  icon: Icons.storefront_outlined,
                                  title: DiscList.emptyCatalogTitle,
                                  body: DiscList.pullDownHint,
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _onRefresh,
                                child: ListView.separated(
                                  controller: _scrollController,
                                  padding: EdgeInsets.fromLTRB(
                                    hPad,
                                    8,
                                    hPad,
                                    28,
                                  ),
                                  itemCount: state.entries.length +
                                      (state.hasMore ? 1 : 0),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 14),
                                  itemBuilder: (context, index) {
                                    if (index >= state.entries.length) {
                                      return Center(
                                        child: state.loadingMore
                                            ? const DiscoveryInlineSkeleton(
                                                height: 28,
                                                padding: EdgeInsets.all(16),
                                              )
                                            : FilledButton.tonal(
                                                onPressed: () => ref
                                                    .read(
                                                      listingCatalogNotifierProvider
                                                          .notifier,
                                                    )
                                                    .loadMore(),
                                                child: Text(DiscList.seeMore),
                                              ),
                                      );
                                    }
                                    final entry = state.entries[index];
                                    final km = entry.distanceKmFrom(origin);
                                    return PrestataireCatalogListCard(
                                      entry: entry,
                                      density: CatalogCardDensity.expanded,
                                      distanceKm: km.isFinite ? km : null,
                                    );
                                  },
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              DiscList.allPrestatairesTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
