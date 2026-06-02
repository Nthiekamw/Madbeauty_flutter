import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/service_category.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../prestataire/providers/prestataire_filters_provider.dart';

/// Catégories en carrousel (icône + pastels, style maquette).
class ListingCategoryStrip extends ConsumerWidget {
  const ListingCategoryStrip({
    super.key,
    required this.categories,
  });

  final List<ServiceCategory> categories;

  static const _pastels = [
    Color(0xFFFFE8DC),
    Color(0xFFFFE4EC),
    Color(0xFFEDE4FF),
    Color(0xFFE0F5EE),
    Color(0xFFFFF0D6),
    Color(0xFFE8F0FF),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final activeId = ref.watch(prestatairesFilterProvider).categoryId;

    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = activeId == cat.id;
          final bg = _pastels[index % _pastels.length];
          final icon = _iconForCategory(cat.nom);

          return Material(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : bg,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                ref.read(prestatairesFilterProvider.notifier).setCategoryId(
                      selected ? null : cat.id,
                    );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 80,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.08),
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 26, color: theme.colorScheme.primary),
                    const SizedBox(height: 6),
                    Text(
                      cat.nom,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 1.15,
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
    if (n.contains('coiff')) return Icons.content_cut_rounded;
    if (n.contains('manuc') || n.contains('ongl')) {
      return Icons.back_hand_outlined;
    }
    if (n.contains('maquill')) return Icons.face_retouching_natural_outlined;
    if (n.contains('pédic')) return Icons.spa_outlined;
    return Icons.auto_awesome_outlined;
  }
}
