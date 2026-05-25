import 'package:flutter/material.dart';

import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/prototype_palette.dart';
import '../../../shared/widgets/app_avatar.dart';

const int _kMaxChips = 3;

/// Carte catalogue (liste verticale) : photo, nom, spécialités, note, ville.
class PrestataireCatalogListCard extends StatelessWidget {
  const PrestataireCatalogListCard({
    super.key,
    required this.entry,
  });

  final PrestataireCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = entry.profile;
    final ville = profile.ville?.trim();
    final url = entry.avatarUrl;
    final display = entry.displayName;
    final rating = profile.noteMoyenne;

    return Material(
      color: isDark
          ? theme.colorScheme.surface.withValues(alpha: 0.92)
          : PrototypePalette.cardWhite,
      elevation: 0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(profile.id),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.outline.withValues(alpha: 0.14)
                  : PrototypePalette.goldLight.withValues(alpha: 0.5),
            ),
            boxShadow: isDark ? null : PrototypePalette.cardShadow(),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LeadingPhoto(
                  imageUrl: url,
                  displayName: display,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              display,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (profile.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Icon(
                                Icons.verified_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                      if (entry.specialtyNames.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...entry.specialtyNames.take(_kMaxChips).map(
                                  (n) => _SpecialtyChip(label: n),
                                ),
                            if (entry.specialtyNames.length > _kMaxChips)
                              _SpecialtyChip(
                                label:
                                    '+${entry.specialtyNames.length - _kMaxChips}',
                                muted: true,
                              ),
                          ],
                        ),
                      ],
                      if (ville != null && ville.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ville,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (rating != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: muted
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
          color: muted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _LeadingPhoto extends StatelessWidget {
  const _LeadingPhoto({
    required this.imageUrl,
    required this.displayName,
  });

  final String? imageUrl;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = imageUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 76,
          height: 76,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => AppAvatar(
              displayName: displayName,
              radius: 38,
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return AppAvatar(
      displayName: displayName,
      radius: 38,
    );
  }
}
