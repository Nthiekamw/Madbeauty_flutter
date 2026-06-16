import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../prestataire/providers/catalog/prestataire_filters_provider.dart';
import '../../providers/catalog_cities_provider.dart';

/// Villes du catalogue en puces horizontales (filtre exact).
class ListingCitiesStrip extends ConsumerWidget {
  const ListingCitiesStrip({
    super.key,
    this.embedded = false,
    this.outlined = true,
  });

  final bool embedded;
  final bool outlined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(catalogCitiesProvider);
    if (cities.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final layout = DiscoveryResponsive.of(context);
    final hPad = embedded ? 0.0 : layout.horizontalPadding;
    final activeVille = ref.watch(prestatairesFilterProvider).ville?.trim();
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(hPad, embedded ? 0 : 2, hPad, 4),
          child: Text(
            DiscList.citiesFilterTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: outlined ? 36.0 : layout.quickFiltersStripHeight,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            scrollDirection: Axis.horizontal,
            itemCount: cities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final city = cities[index];
              final selected =
                  activeVille != null &&
                  activeVille.toLowerCase() == city.toLowerCase();

              final fill = outlined
                  ? (selected
                      ? primary
                      : theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: isDark ? 0.55 : 0.85,
                        ))
                  : (selected
                      ? primary
                      : primary.withValues(alpha: isDark ? 0.18 : 0.1));
              final border = selected
                  ? primary
                  : theme.colorScheme.outline.withValues(
                      alpha: isDark ? 0.28 : 0.22,
                    );
              final fg = selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface;

              return AnimatedScale(
                scale: selected ? 1.02 : 1,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: Material(
                  elevation: selected ? 2 : 0,
                  shadowColor: selected
                      ? primary.withValues(alpha: 0.45)
                      : Colors.transparent,
                  color: fill,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      ref.read(prestatairesFilterProvider.notifier).setVille(
                            selected ? null : city,
                          );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: selected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            city,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontFamily: AppFonts.body,
                              fontWeight:
                                  selected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 11,
                              color: fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
