import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/layout/discovery_responsive.dart';
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
    final layout = DiscoveryResponsive.of(context);
    final cardHeight = layout.homeTrendingCardHeight;
    final visible = entries.length <= limit
        ? entries
        : entries.sublist(0, limit);

    return SizedBox(
      height: cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, __) =>
            SizedBox(width: DiscoveryResponsive.homeTrendingCardGap),
        itemBuilder: (context, index) {
          return _TrendingCard(
            entry: visible[index],
            cardWidth: layout.homeTrendingCardWidth,
            cardHeight: cardHeight,
          );
        },
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({
    required this.entry,
    required this.cardWidth,
    required this.cardHeight,
  });

  final PrestataireCatalogEntry entry;
  final double cardWidth;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final theme = Theme.of(context);
    final title = normalizeSingleLineText(entry.displayName);
    final safeTitle = title.isEmpty ? 'Salon' : title;
    final bookings = entry.reviewCount ?? 0;
    final titleSize = layout.homeTrendingTitleFontSize(cardWidth);
    final bodySize = layout.homeTrendingBodyFontSize(cardWidth);
    final inset = (cardWidth * 0.06).clamp(8.0, 12.0);

    return SizedBox(
      width: cardWidth,
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
                    height: cardHeight,
                    width: cardWidth,
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
                    left: inset,
                    right: inset,
                    bottom: inset,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          safeTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w800,
                            fontSize: titleSize,
                            color: AppColors.white,
                            height: 1.12,
                          ),
                        ),
                        SizedBox(height: (cardHeight * 0.012).clamp(2.0, 4.0)),
                        Text(
                          DiscHome.trendingBookings(bookings),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: bodySize,
                            color: AppColors.white.withValues(alpha: 0.88),
                            height: 1.1,
                          ),
                        ),
                      ],
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
