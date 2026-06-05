import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../prestataire/models/prestataires_filter_state.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';
import '../models/listing_catalog_layout.dart';
import '../models/listing_quick_filter.dart';
import 'listing_filters_panel.dart';
import 'listing_layout_toggle.dart';

Future<void> showListingFiltersSheet(
  BuildContext context, {
  required List<ServiceCategory> categories,
  required ListingViewMode viewMode,
  required ValueChanged<ListingViewMode> onViewModeChanged,
  required ListingCatalogLayout catalogLayout,
  required ValueChanged<ListingCatalogLayout> onCatalogLayoutChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return Consumer(
        builder: (context, ref, _) {
          final theme = Theme.of(context);
          final hPad = DiscoveryResponsive.of(context).horizontalPadding;
          final filters = ref.watch(prestatairesFilterProvider);
          final maxH = MediaQuery.sizeOf(context).height * 0.82;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 4),
                    child: Text(
                      DiscList.filtersTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SheetSection(
                            title: DiscList.modeList,
                            child: SegmentedButton<ListingViewMode>(
                              style: SegmentedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              segments: const [
                                ButtonSegment<ListingViewMode>(
                                  value: ListingViewMode.list,
                                  icon: Icon(Icons.view_list_rounded, size: 17),
                                  label: Text(DiscList.modeList),
                                ),
                                ButtonSegment<ListingViewMode>(
                                  value: ListingViewMode.map,
                                  icon: Icon(Icons.map_rounded, size: 17),
                                  label: Text(DiscList.modeMap),
                                ),
                              ],
                              selected: {viewMode},
                              onSelectionChanged: (selection) {
                                if (selection.isEmpty) return;
                                onViewModeChanged(selection.first);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SheetSection(
                            title: DiscList.layoutSectionTitle,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ListingLayoutToggle(
                                layout: catalogLayout,
                                onChanged: onCatalogLayoutChanged,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SheetSection(
                            title: DiscList.sortLabel,
                            child: SegmentedButton<PrestatairesSort>(
                              segments: [
                                ButtonSegment<PrestatairesSort>(
                                  value: PrestatairesSort.rating,
                                  icon: const Icon(
                                    Icons.star_outline_rounded,
                                    size: 17,
                                  ),
                                  label: Text(DiscList.sortRating),
                                ),
                                ButtonSegment<PrestatairesSort>(
                                  value: PrestatairesSort.distance,
                                  icon: const Icon(
                                    Icons.near_me_outlined,
                                    size: 17,
                                  ),
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
                          const SizedBox(height: 16),
                          _SheetSection(
                            title: DiscList.quickFiltersTitle,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ListingQuickFilter.featured
                                  .where((f) => f.id != 'all')
                                  .map((filter) {
                                final selected =
                                    filters.activeQuickFilterId == filter.id;
                                return _SheetFilterChip(
                                  label: filter.label,
                                  icon: filter.icon,
                                  selected: selected,
                                  onTap: () {
                                    ref
                                        .read(
                                          prestatairesFilterProvider.notifier,
                                        )
                                        .applyQuickFilter(filter);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          if (categories.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _SheetSection(
                              title: DiscList.svcTypeLabel,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _SheetFilterChip(
                                    label: DiscList.chipAll,
                                    icon: Icons.grid_view_rounded,
                                    selected: filters.categoryId == null,
                                    onTap: () => ref
                                        .read(prestatairesFilterProvider.notifier)
                                        .setCategoryId(null),
                                  ),
                                  for (final c in categories)
                                    _SheetFilterChip(
                                      label: c.nom,
                                      icon: Icons.category_outlined,
                                      selected: filters.categoryId == c.id,
                                      onTap: () {
                                        ref
                                            .read(
                                              prestatairesFilterProvider.notifier,
                                            )
                                            .setCategoryId(
                                              filters.categoryId == c.id
                                                  ? null
                                                  : c.id,
                                            );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref
                                  .read(prestatairesFilterProvider.notifier)
                                  .resetQuickFilters();
                            },
                            child: Text(DiscList.quickFiltersReset),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: const Text(DiscList.filtersDone),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.55 : 0.96,
        ),
        borderRadius: DiscoveryStyles.cardBorderRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetFilterChip extends StatelessWidget {
  const _SheetFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final fill = selected
        ? primary
        : primary.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.18 : 0.08,
          );

    return Material(
      color: fill,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? theme.colorScheme.onPrimary : primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
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
