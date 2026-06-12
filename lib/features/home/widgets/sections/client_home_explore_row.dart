import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_network_image.dart';
import '../../providers/home_feed_provider.dart';

/// Filtres horizontaux par service (catégories accueil).
class ClientHomeExploreRow extends ConsumerWidget {
  const ClientHomeExploreRow({super.key});

  static const _chipHeight = 34.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(homeFeedSelectionProvider);
    final selectedAll = selection?.allServices ?? true;
    final selectedMain = selection?.mainService;

    return SizedBox(
      height: _chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 1 + PrestaMainService.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ServiceFilterChip(
              label: DiscHome.filterAll,
              imageUrl: null,
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
            imageUrl: PrestataireServiceCatalog.coverImageUrl(service),
            icon: PrestataireServiceCatalog.icon(service),
            selected: !selectedAll && selectedMain == service,
            onTap: () => ref
                .read(homeFeedSelectionProvider.notifier)
                .setMainServiceFilter(mainService: service),
          );
        },
      ),
    );
  }
}

class _ServiceFilterChip extends StatelessWidget {
  const _ServiceFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.imageUrl,
  });

  final String label;
  final IconData icon;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = selected
        ? theme.colorScheme.primary
        : (isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.filterChipInactive);
    final fg = selected
        ? theme.colorScheme.onPrimary
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl != null && !selected)
                ClipOval(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: AppNetworkImage(
                      url: imageUrl!,
                      fit: BoxFit.cover,
                      error: Icon(icon, size: 12, color: fg),
                    ),
                  ),
                )
              else
                Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
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
