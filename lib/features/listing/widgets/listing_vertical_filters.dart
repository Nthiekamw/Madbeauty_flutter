import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../prestataire/models/prestataires_filter_state.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';
import '../models/listing_quick_filter.dart';

/// Filtres rapides empilés verticalement sous la barre de recherche.
class ListingVerticalFilters extends ConsumerWidget {
  const ListingVerticalFilters({
    super.key,
    this.onStyleQuerySelected,
  });

  final ValueChanged<String>? onStyleQuerySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final filters = ref.watch(prestatairesFilterProvider);
    final activeId = filters.activeQuickFilterId ??
        (filters.query.isEmpty &&
                filters.categoryId == null &&
                !filters.availableOnly
            ? 'all'
            : null);

    final utility = ListingQuickFilter.utilityOnly;
    final specialties = ListingQuickFilter.specialtyOnly;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (activeId != null && activeId != 'all')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ref
                      .read(prestatairesFilterProvider.notifier)
                      .resetQuickFilters();
                  onStyleQuerySelected?.call('');
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(DiscList.quickFiltersReset),
              ),
            ),
          ...utility.map(
            (filter) => _filterButton(
              context,
              ref,
              filter: filter,
              activeId: activeId,
              filters: filters,
            ),
          ),
          if (specialties.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
              child: Text(
                DiscList.specialtyFiltersTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            ...specialties.map(
              (filter) => _filterButton(
                context,
                ref,
                filter: filter,
                activeId: activeId,
                filters: filters,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterButton(
    BuildContext context,
    WidgetRef ref, {
    required ListingQuickFilter filter,
    required String? activeId,
    required PrestatairesFilterState filters,
  }) {
    final selected = filter.id == 'all'
        ? activeId == 'all' ||
            (activeId == null &&
                filters.query.isEmpty &&
                filters.categoryId == null &&
                !filters.availableOnly)
        : activeId == filter.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _VerticalFilterButton(
        filter: filter,
        selected: selected,
        onTap: () {
          ref.read(prestatairesFilterProvider.notifier).applyQuickFilter(filter);
          if (filter.kind == ListingQuickFilterKind.styleQuery) {
            onStyleQuerySelected?.call(filter.query ?? '');
          } else {
            onStyleQuerySelected?.call('');
          }
        },
      ),
    );
  }
}

class _VerticalFilterButton extends StatelessWidget {
  const _VerticalFilterButton({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final ListingQuickFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: selected
          ? primary.withValues(alpha: isDark ? 0.22 : 0.12)
          : AppColors.cardSurfaceFor(theme.brightness),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? primary
                  : theme.colorScheme.outline.withValues(
                      alpha: isDark ? 0.35 : 0.12,
                    ),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  filter.icon,
                  size: 20,
                  color: selected
                      ? primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    filter.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, size: 18, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
