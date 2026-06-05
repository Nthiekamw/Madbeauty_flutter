import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../prestataire/models/prestataires_filter_state.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';

enum ListingViewMode { list, map }

/// Filtres avancés compacts : catégories API, tri, mode liste / carte.
class ListingFiltersPanel extends ConsumerStatefulWidget {
  const ListingFiltersPanel({
    super.key,
    required this.categories,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  final List<ServiceCategory> categories;
  final ListingViewMode viewMode;
  final ValueChanged<ListingViewMode> onViewModeChanged;

  @override
  ConsumerState<ListingFiltersPanel> createState() =>
      _ListingFiltersPanelState();
}

class _ListingFiltersPanelState extends ConsumerState<ListingFiltersPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(prestatairesFilterProvider);
    final isDark = theme.brightness == Brightness.dark;
    final hasCategory = filters.categoryId != null;
    final advancedActive = hasCategory || _expanded;

    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(
            alpha: isDark ? 0.88 : 0.94,
          ),
          borderRadius: DiscoveryStyles.chipBorderRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: DiscoveryStyles.chipBorderRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DiscList.advancedFiltersTitle,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (hasCategory)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '1',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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
                selected: {widget.viewMode},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  widget.onViewModeChanged(selection.first);
                },
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      DiscList.sortLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<PrestatairesSort>(
                      segments: [
                        ButtonSegment<PrestatairesSort>(
                          value: PrestatairesSort.rating,
                          icon: const Icon(Icons.star_outline_rounded, size: 17),
                          label: Text(DiscList.sortRating),
                        ),
                        ButtonSegment<PrestatairesSort>(
                          value: PrestatairesSort.distance,
                          icon: const Icon(Icons.near_me_outlined, size: 17),
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
                    if (widget.categories.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        DiscList.svcTypeLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CategoryChip(
                            label: DiscList.chipAll,
                            selected: filters.categoryId == null,
                            onTap: () => ref
                                .read(prestatairesFilterProvider.notifier)
                                .setCategoryId(null),
                          ),
                          for (final c in widget.categories)
                            _CategoryChip(
                              label: c.nom,
                              selected: filters.categoryId == c.id,
                              onTap: () {
                                ref
                                    .read(prestatairesFilterProvider.notifier)
                                    .setCategoryId(
                                      filters.categoryId == c.id ? null : c.id,
                                    );
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ] else if (advancedActive && hasCategory) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Wrap(
                  spacing: 8,
                  children: widget.categories
                      .where((c) => c.id == filters.categoryId)
                      .map(
                        (c) => InputChip(
                          label: Text(c.nom),
                          onDeleted: () => ref
                              .read(prestatairesFilterProvider.notifier)
                              .setCategoryId(null),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: selected
          ? primary.withValues(alpha: 0.14)
          : theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.5 : 0.85,
            ),
      shape: RoundedRectangleBorder(
        borderRadius: DiscoveryStyles.chipBorderRadius,
        side: BorderSide(
          color: selected
              ? primary
              : theme.colorScheme.outline.withValues(alpha: 0.22),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: DiscoveryStyles.chipBorderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? primary : null,
            ),
          ),
        ),
      ),
    );
  }
}

