import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';

/// Catégories en puces horizontales (icône + libellé sur une ligne).
class ListingCategoryStrip extends ConsumerWidget {
  const ListingCategoryStrip({
    super.key,
    required this.categories,
    this.embedded = false,
  });

  final List<ServiceCategory> categories;
  final bool embedded;

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
    final hPad = embedded ? 0.0 : DiscoveryResponsive.of(context).horizontalPadding;
    final activeId = ref.watch(prestatairesFilterProvider).categoryId;
    final accents = _accentPalette(theme.colorScheme);

    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: DiscoveryResponsive.of(context).quickFiltersStripHeight,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(hPad, 2, hPad, 0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = activeId == cat.id;
          final accent = accents[index % accents.length];
          final primary = theme.colorScheme.primary;
          final fill = selected
              ? primary
              : accent.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.18 : 0.1,
                );
          final border = selected
              ? primary
              : accent.withValues(alpha: 0.35);

          return Material(
            color: fill,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: border, width: selected ? 1.5 : 1),
            ),
            child: InkWell(
              onTap: () {
                ref.read(prestatairesFilterProvider.notifier).setCategoryId(
                      selected ? null : cat.id,
                    );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForCategory(cat.nom),
                      size: 14,
                      color: selected ? theme.colorScheme.onPrimary : accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cat.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        },
      ),
    );
  }

  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('coiff') || n.contains('tress')) {
      return Icons.content_cut_rounded;
    }
    if (n.contains('soin') && n.contains('capill')) {
      return Icons.spa_outlined;
    }
    if (n.contains('manuc') || n.contains('ongl')) {
      return Icons.back_hand_outlined;
    }
    if (n.contains('maquill')) return Icons.face_retouching_natural_outlined;
    if (n.contains('pédic') || n.contains('pedic')) return Icons.spa_outlined;
    return Icons.auto_awesome_outlined;
  }
}
