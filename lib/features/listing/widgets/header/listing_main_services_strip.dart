import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../prestataire/models/prestataires_filter_state.dart';
import '../../../prestataire/providers/catalog/prestataire_filters_provider.dart';

/// Catégories principales (icône + libellé) — réparties uniformément.
class ListingMainServicesStrip extends ConsumerWidget {
  const ListingMainServicesStrip({super.key});

  static const _tileSize = 52.0;
  static const _stripHeight = 82.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final filters = ref.watch(prestatairesFilterProvider);
    final activeQuery = filters.query.trim().toLowerCase();
    final services = PrestaMainService.values;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 2),
      child: SizedBox(
        height: _stripHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fitsInRow =
                constraints.maxWidth >= services.length * 72.0;

            if (fitsInRow) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final service in services)
                    _ServiceTile(
                      label: PrestataireServiceCatalog.label(service),
                      icon: PrestataireServiceCatalog.icon(service),
                      selected: activeQuery ==
                              PrestataireServiceCatalog.label(service)
                                  .toLowerCase() &&
                          filters.categoryId == null,
                      onTap: () => _onTap(ref, service, activeQuery, filters),
                      primary: theme.colorScheme.primary,
                      isDark: theme.brightness == Brightness.dark,
                      expanded: true,
                    ),
                ],
              );
            }

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: services.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceTile(
                  label: PrestataireServiceCatalog.label(service),
                  icon: PrestataireServiceCatalog.icon(service),
                  selected: activeQuery ==
                          PrestataireServiceCatalog.label(service)
                              .toLowerCase() &&
                      filters.categoryId == null,
                  onTap: () => _onTap(ref, service, activeQuery, filters),
                  primary: theme.colorScheme.primary,
                  isDark: theme.brightness == Brightness.dark,
                  expanded: false,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _onTap(
    WidgetRef ref,
    PrestaMainService service,
    String activeQuery,
    PrestatairesFilterState filters,
  ) {
    final label = PrestataireServiceCatalog.label(service);
    final selected =
        activeQuery == label.toLowerCase() && filters.categoryId == null;
    final notifier = ref.read(prestatairesFilterProvider.notifier);
    if (selected) {
      notifier.resetQuickFilters();
      return;
    }
    notifier.setQuery(label);
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.primary,
    required this.isDark,
    required this.expanded,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;
  final bool isDark;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boxFill = selected
        ? primary.withValues(alpha: isDark ? 0.28 : 0.14)
        : (isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.filterChipInactive);
    final iconColor = selected ? primary : AppColors.filterChipInactiveText;
    final borderColor = selected
        ? primary.withValues(alpha: 0.55)
        : theme.colorScheme.outline.withValues(alpha: isDark ? 0.22 : 0.12);

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: expanded ? null : 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: ListingMainServicesStrip._tileSize,
                height: ListingMainServicesStrip._tileSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: boxFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.5,
                  color: theme.colorScheme.onSurface,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
