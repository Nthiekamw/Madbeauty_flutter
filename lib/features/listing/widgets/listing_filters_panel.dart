import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../prestataire/models/prestataires_filter_state.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';

enum ListingViewMode { list, map }

/// Filtres : tri, catégories, mode liste / carte.
class ListingFiltersPanel extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(prestatairesFilterProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(
            alpha: isDark ? 0.9 : 0.96,
          ),
          borderRadius: DiscoveryStyles.cardBorderRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DiscList.filtersTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                DiscList.sortLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: AppFonts.body,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PrestatairesSort>(
                segments: [
                  ButtonSegment<PrestatairesSort>(
                    value: PrestatairesSort.rating,
                    icon: const Icon(Icons.star_outline_rounded, size: 18),
                    label: Text(DiscList.sortRating),
                  ),
                  ButtonSegment<PrestatairesSort>(
                    value: PrestatairesSort.distance,
                    icon: const Icon(Icons.near_me_outlined, size: 18),
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
              if (categories.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  DiscList.svcTypeLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _CategoryChip(
                          label: DiscList.chipAll,
                          selected: filters.categoryId == null,
                          onTap: () => ref
                              .read(prestatairesFilterProvider.notifier)
                              .setCategoryId(null),
                        );
                      }
                      final c = categories[index - 1];
                      return _CategoryChip(
                        label: c.nom,
                        selected: filters.categoryId == c.id,
                        onTap: () {
                          ref
                              .read(prestatairesFilterProvider.notifier)
                              .setCategoryId(
                                filters.categoryId == c.id ? null : c.id,
                              );
                        },
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SegmentedButton<ListingViewMode>(
                segments: const [
                  ButtonSegment<ListingViewMode>(
                    value: ListingViewMode.list,
                    icon: Icon(Icons.view_list_rounded, size: 18),
                    label: Text(DiscList.modeList),
                  ),
                  ButtonSegment<ListingViewMode>(
                    value: ListingViewMode.map,
                    icon: Icon(Icons.map_rounded, size: 18),
                    label: Text(DiscList.modeMap),
                  ),
                ],
                selected: {viewMode},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) return;
                  onViewModeChanged(selection.first);
                },
              ),
            ],
          ),
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
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
