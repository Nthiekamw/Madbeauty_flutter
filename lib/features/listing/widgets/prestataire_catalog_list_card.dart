import 'package:flutter/material.dart';

import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
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
    final primary = theme.colorScheme.primary;
    final profile = entry.profile;
    final ville = profile.ville?.trim();
    final url = entry.avatarUrl;
    final display = entry.displayName;
    final rating = profile.noteMoyenne;

    return Material(
      color: Colors.transparent,
      borderRadius: DiscoveryStyles.catalogListCardBorderRadius,
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(profile.id),
        borderRadius: DiscoveryStyles.catalogListCardBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.catalogListCardBorderRadius,
            color: theme.colorScheme.surface.withValues(
              alpha: isDark ? 0.92 : 0.98,
            ),
            border: Border.all(
              color: primary.withValues(alpha: isDark ? 0.1 : 0.08),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LeadingPhoto(imageUrl: url, displayName: display),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  display,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: AppFonts.display,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              if (profile.isVerified)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6, top: 2),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.verified_rounded,
                                      color: primary,
                                      size: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (ville != null && ville.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 3),
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
                          if (entry.specialtyNames.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.07 : 0.04),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: primary.withValues(alpha: isDark ? 0.1 : 0.07),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (rating != null) ...[
                      Icon(Icons.star_rounded, size: 16, color: const Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Disponible',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: AppFonts.body,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Voir',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
