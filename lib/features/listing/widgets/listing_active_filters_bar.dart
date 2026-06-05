import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../prestataire/models/prestataires_filter_state.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';
import '../models/listing_quick_filter.dart';

/// Filtres actifs sous la barre de recherche (retrait rapide).
class ListingActiveFiltersBar extends ConsumerWidget {
  const ListingActiveFiltersBar({
    super.key,
    this.categories = const [],
    this.onClearSearch,
  });

  final List<ServiceCategory> categories;
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(prestatairesFilterProvider);
    if (!filters.hasActiveFilters) return const SizedBox.shrink();

    final chips = _buildChips(context, ref, filters);
    if (chips.isEmpty) return const SizedBox.shrink();

    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            if (index == chips.length) {
              return ActionChip(
                visualDensity: VisualDensity.compact,
                label: Text(
                  DiscList.quickFiltersReset,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onPressed: () {
                  ref.read(prestatairesFilterProvider.notifier).resetQuickFilters();
                  onClearSearch?.call();
                },
              );
            }
            return chips[index];
          },
        ),
      ),
    );
  }

  List<Widget> _buildChips(
    BuildContext context,
    WidgetRef ref,
    PrestatairesFilterState filters,
  ) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final chips = <Widget>[];

    void addChip(String label, VoidCallback onDeleted) {
      chips.add(
        InputChip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
            ),
          ),
          deleteIcon: const Icon(Icons.close_rounded, size: 16),
          onDeleted: onDeleted,
          backgroundColor: primary.withValues(alpha: 0.1),
          side: BorderSide(color: primary.withValues(alpha: 0.25)),
        ),
      );
    }

    final query = filters.query.trim();
    if (query.isNotEmpty) {
      addChip('« $query »', () {
        ref.read(prestatairesFilterProvider.notifier).setQuery('');
        onClearSearch?.call();
      });
    }

    if (filters.availableOnly) {
      addChip(DiscClientWorkspace.availableBadge, () {
        ref.read(prestatairesFilterProvider.notifier).resetQuickFilters();
      });
    }

    if (filters.categoryId != null) {
      final matches =
          categories.where((c) => c.id == filters.categoryId);
      final cat = matches.isEmpty ? null : matches.first;
      addChip(cat?.nom ?? DiscList.svcTypeLabel, () {
        ref.read(prestatairesFilterProvider.notifier).setCategoryId(null);
      });
    }

    final quickId = filters.activeQuickFilterId;
    if (quickId != null && quickId != 'all') {
      final quickMatches =
          ListingQuickFilter.featured.where((f) => f.id == quickId);
      final quick = quickMatches.isEmpty ? null : quickMatches.first;
      if (quick != null &&
          quick.kind != ListingQuickFilterKind.availableOnly &&
          quick.kind != ListingQuickFilterKind.categoryId) {
        addChip(quick.label, () {
          ref.read(prestatairesFilterProvider.notifier).resetQuickFilters();
          onClearSearch?.call();
        });
      }
    }

    if (filters.sort == PrestatairesSort.rating &&
        filters.activeQuickFilterId != 'top') {
      addChip(DiscList.sortRating, () {
        ref.read(prestatairesFilterProvider.notifier).setSort(
              PrestatairesSort.distance,
            );
      });
    }

    return chips;
  }
}
