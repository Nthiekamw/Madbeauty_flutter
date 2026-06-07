import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';
import '../models/listing_quick_filter.dart';

/// Bandeau de filtres rapides prédéfinis (puces compactes).
class ListingQuickFiltersStrip extends ConsumerWidget {
  const ListingQuickFiltersStrip({
    super.key,
    this.onStyleQuerySelected,
    this.dense = true,
    this.showTitle = true,
    this.embedded = false,
    this.filters,
    this.outlined = false,
    this.stripHeight,
  });

  final ValueChanged<String>? onStyleQuerySelected;
  final bool dense;
  final bool showTitle;
  final bool embedded;

  /// Liste personnalisée ; par défaut [ListingQuickFilter.featured].
  final List<ListingQuickFilter>? filters;

  /// Style contour (catalogue, maquette).
  final bool outlined;

  final double? stripHeight;

  static List<Color> _accentPalette(ColorScheme scheme) {
    return [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      Color.lerp(scheme.primary, scheme.secondary, 0.5)!,
      Color.lerp(scheme.secondary, scheme.tertiary, 0.5)!,
      scheme.outline,
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final layout = DiscoveryResponsive.of(context);
    final state = ref.watch(prestatairesFilterProvider);
    final hPad = embedded ? 0.0 : layout.horizontalPadding;
    final accents = _accentPalette(theme.colorScheme);
    final items = filters ?? ListingQuickFilter.featured;
    final hasAllChip = items.any((f) => f.id == 'all');

    final activeId = state.activeQuickFilterId ??
        (hasAllChip &&
                state.query.isEmpty &&
                state.categoryId == null &&
                !state.availableOnly
            ? 'all'
            : null);

    final height = stripHeight ?? (outlined ? 36.0 : layout.quickFiltersStripHeight);

    return Padding(
      padding: EdgeInsets.only(top: dense ? 0 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTitle)
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
          if (showTitle) const SizedBox(height: 4),
          SizedBox(
            height: height,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = items[index];
                final selected = filter.id == 'all'
                    ? activeId == 'all' ||
                        (activeId == null &&
                            state.query.isEmpty &&
                            state.categoryId == null &&
                            !state.availableOnly)
                    : activeId == filter.id;
                final accent = accents[index % accents.length];

                return _QuickFilterChip(
                  filter: filter,
                  selected: selected,
                  accentColor: accent,
                  outlined: outlined,
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
    required this.accentColor,
    required this.onTap,
    this.outlined = false,
  });

  final ListingQuickFilter filter;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final fill = outlined
        ? (selected
            ? primary.withValues(alpha: isDark ? 0.22 : 0.1)
            : AppColors.cardSurfaceFor(theme.brightness))
        : (selected
            ? primary
            : accentColor.withValues(alpha: isDark ? 0.18 : 0.1));
    final border = outlined
        ? (selected
            ? primary.withValues(alpha: 0.55)
            : theme.colorScheme.outline.withValues(alpha: isDark ? 0.28 : 0.22))
        : (selected ? primary : accentColor.withValues(alpha: 0.35));
    final fg = selected && !outlined
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final iconColor = outlined
        ? (selected ? primary : theme.colorScheme.onSurfaceVariant)
        : (selected ? theme.colorScheme.onPrimary : accentColor);

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(outlined ? 20 : 16),
        side: BorderSide(color: border, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(outlined ? 20 : 16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: outlined ? 12 : 10,
            vertical: outlined ? 7 : 5,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                filter.icon,
                size: outlined ? 14 : 13,
                color: iconColor,
              ),
              const SizedBox(width: 5),
              Text(
                filter.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                  fontSize: outlined ? 11 : 10,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
