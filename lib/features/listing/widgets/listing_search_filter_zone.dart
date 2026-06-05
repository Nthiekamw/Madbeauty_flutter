import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import 'listing_category_strip.dart';
import 'listing_quick_filters_strip.dart';

/// Zone filtres unifiée : catégories + puces rapides dans un même bloc visuel.
class ListingSearchFilterZone extends ConsumerWidget {
  const ListingSearchFilterZone({
    super.key,
    required this.categories,
    this.onStyleQuerySelected,
  });

  final List<ServiceCategory> categories;
  final ValueChanged<String>? onStyleQuerySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final hasCategories = categories.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.72 : 0.98,
          ),
          borderRadius: DiscoveryStyles.cardBorderRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: theme.brightness == Brightness.light
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasCategories) ...[
                _ZoneLabel(
                  icon: Icons.category_outlined,
                  label: DiscList.categoriesLabel,
                ),
                const SizedBox(height: 8),
                ListingCategoryStrip(
                  categories: categories,
                  embedded: true,
                ),
                const SizedBox(height: 12),
              ],
              _ZoneLabel(
                icon: Icons.tune_rounded,
                label: DiscList.filtersQuickLabel,
              ),
              const SizedBox(height: 8),
              ListingQuickFiltersStrip(
                embedded: true,
                showTitle: false,
                onStyleQuerySelected: onStyleQuerySelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  const _ZoneLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Icon(icon, size: 15, color: primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
