import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/text_normalizer.dart';
import '../../../prestataire/widgets/public/media/prestataire_realisation_carousel_scope.dart';

/// Cartes portrait « Tendances cette semaine ».
class PrestataireHomeTrendingList extends StatelessWidget {
  const PrestataireHomeTrendingList({
    super.key,
    required this.entries,
    this.limit = 10,
  });

  final List<PrestataireCatalogEntry> entries;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final visible = entries.length <= limit
        ? entries
        : entries.sublist(0, limit);

    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _TrendingCard(entry: visible[index]);
        },
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.entry});

  final PrestataireCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = normalizeSingleLineText(entry.displayName);
    final safeTitle = title.isEmpty ? 'Salon' : title;
    final bookings = entry.reviewCount ?? 0;

    return SizedBox(
      width: 132,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: () => context.pushPrestataireDetail(entry.profile.id),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PrestataireRealisationCarouselScope(
                    prestataireId: entry.profile.id,
                    height: 196,
                    width: 132,
                    fallbackDisplayName: safeTitle,
                    fallbackAvatarUrl: entry.avatarUrl,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                        stops: const [0.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        width: 116,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              safeTitle,
                              softWrap: true,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                                color: AppColors.white,
                                height: 1.12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DiscHome.trendingBookings(bookings),
                              softWrap: true,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 8,
                                color: AppColors.white.withValues(alpha: 0.88),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
