import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';
import '../models/listing_quick_filter.dart';

/// Bandeau de filtres rapides prédéfinis (puces compactes).
class ListingQuickFiltersStrip extends ConsumerWidget {
  const ListingQuickFiltersStrip({
    super.key,
    this.onStyleQuerySelected,
    this.dense = true,
  });

  final ValueChanged<String>? onStyleQuerySelected;
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final layout = DiscoveryResponsive.of(context);
    final filters = ref.watch(prestatairesFilterProvider);
    final hPad = layout.horizontalPadding;
    final activeId = filters.activeQuickFilterId ??
        (filters.query.isEmpty &&
                filters.categoryId == null &&
                !filters.availableOnly
            ? 'all'
            : null);

    return Padding(
      padding: EdgeInsets.only(top: dense ? 4 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                Text(
                  DiscList.quickFiltersTitle,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (activeId != null && activeId != 'all')
                  TextButton(
                    onPressed: () {
                      ref
                          .read(prestatairesFilterProvider.notifier)
                          .resetQuickFilters();
                      onStyleQuerySelected?.call('');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      DiscList.quickFiltersReset,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: layout.quickFiltersStripHeight,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              scrollDirection: Axis.horizontal,
              itemCount: ListingQuickFilter.featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final filter = ListingQuickFilter.featured[index];
                final selected = filter.id == 'all'
                    ? activeId == 'all' ||
                        (activeId == null &&
                            filters.query.isEmpty &&
                            filters.categoryId == null &&
                            !filters.availableOnly)
                    : activeId == filter.id;

                return _QuickFilterChip(
                  filter: filter,
                  selected: selected,
                  onTap: () {
                    ref
                        .read(prestatairesFilterProvider.notifier)
                        .applyQuickFilter(filter);
                    if (filter.kind == ListingQuickFilterKind.styleQuery) {
                      onStyleQuerySelected?.call(filter.query ?? '');
                    } else {
                      onStyleQuerySelected?.call('');
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  const _QuickFilterChip({
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

    return Material(
      color: selected
          ? primary
          : theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.55 : 0.9,
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected
              ? primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon,
                size: 14,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                filter.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
