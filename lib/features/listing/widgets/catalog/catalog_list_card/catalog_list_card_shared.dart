import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';

const int kCatalogMaxChipsCompact = 2;
const int kCatalogMaxChipsExpanded = 4;

String? catalogCardTeaserText(String? description, String? bio) {
  final d = description?.trim();
  if (d != null && d.isNotEmpty) return d;
  final b = bio?.trim();
  if (b != null && b.isNotEmpty) return b;
  return null;
}

String catalogCardLocationLabel(String ville, double? distanceKm) {
  final hasKm =
      distanceKm != null && distanceKm.isFinite && distanceKm < 500;
  if (hasKm) {
    return '$ville · ${DiscClientWorkspace.distanceKm(distanceKm)}';
  }
  return ville;
}

class CatalogCardRatingBadge extends StatelessWidget {
  const CatalogCardRatingBadge({
    super.key,
    required this.rating,
    required this.compact,
  });

  final double rating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.scrimDark55,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 12 : 14,
            color: AppColors.starGold,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 9.5 : 11,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogCardSpecialtyChip extends StatelessWidget {
  const CatalogCardSpecialtyChip({
    super.key,
    required this.label,
    this.muted = false,
  });

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: muted
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: muted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
