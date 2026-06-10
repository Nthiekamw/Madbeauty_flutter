import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../providers/home_feed_provider.dart';
import '../shared/client_home_section_header.dart';

/// Filtres horizontaux par service (Inspirations).
class ClientHomeExploreRow extends ConsumerWidget {
  const ClientHomeExploreRow({super.key});

  static const _chipHeight = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(homeFeedSelectionProvider);
    final selectedAll = selection?.allServices ?? true;
    final selectedMain = selection?.mainService;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ClientHomeSectionHeader(
          title: DiscHome.inspireTitle,
          subtitle: DiscHome.inspireSub,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: _chipHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 1 + PrestaMainService.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _ServiceFilterChip(
                  label: DiscHome.filterAll,
                  icon: Icons.grid_view_rounded,
                  selected: selectedAll,
                  onTap: () => ref
                      .read(homeFeedSelectionProvider.notifier)
                      .setMainServiceFilter(allServices: true),
                );
              }
              final service = PrestaMainService.values[index - 1];
              return _ServiceFilterChip(
                label: PrestataireServiceCatalog.label(service),
                icon: PrestataireServiceCatalog.icon(service),
                selected: !selectedAll && selectedMain == service,
                onTap: () => ref
                    .read(homeFeedSelectionProvider.notifier)
                    .setMainServiceFilter(mainService: service),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ServiceFilterChip extends StatelessWidget {
  const _ServiceFilterChip({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = selected
        ? Theme.of(context).colorScheme.primary
        : (isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.filterChipInactive);
    final fg = selected
        ? Theme.of(context).colorScheme.onPrimary
        : (isDark
            ? AppColors.darkOnSurface
            : AppColors.filterChipInactiveText);

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w600,
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
