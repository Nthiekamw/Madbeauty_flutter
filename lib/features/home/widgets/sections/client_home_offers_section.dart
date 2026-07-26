import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/supabase/prestataire/boutique/pack_offre_service.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../../../shared/widgets/app/app_network_image.dart';
import '../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../providers/home_featured_packs_provider.dart';
import '../shared/client_home_section_header.dart';
import '../catalog/prestataire_catalog_section_empty.dart';

/// Section accueil « Offres spéciales » (cartes portrait).
class ClientHomeOffersSection extends ConsumerWidget {
  const ClientHomeOffersSection({super.key});

  static const double _listHeight = 188;
  static const double _listHeightWeb = 200;
  static const double _cardWidth = 132;
  static const double _cardWidthWeb = 144;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeFeaturedPacksProvider);
    final web = DiscoveryResponsive.of(context).useWebSiteLayout;
    final listHeight = web ? _listHeightWeb : _listHeight;
    final cardWidth = web ? _cardWidthWeb : _cardWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: DiscHome.offersTitle,
          compact: true,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(),
        ),
        const SizedBox(height: 8),
        async.when(
          loading: () => _OffersSkeleton(
            listHeight: listHeight,
            cardWidth: cardWidth,
          ),
          error: (_, __) => DiscoverySectionError(
            message: DiscHome.offersLoadFail,
            onRetry: () => ref.invalidate(homeFeaturedPacksProvider),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return PrestataireCatalogSectionEmpty(
                compact: true,
                title: DiscHome.offersEmptyTitle,
                body: DiscHome.offersEmptyBody,
              );
            }
            return SizedBox(
              height: listHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return _HomeOfferCard(
                    entry: entries[index],
                    width: cardWidth,
                    height: listHeight,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HomeOfferCard extends StatelessWidget {
  const _HomeOfferCard({
    required this.entry,
    required this.width,
    required this.height,
  });

  final PackOffreHomeEntry entry;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pack = entry.pack;
    final image = pack.imageUrl?.trim();
    final discount = entry.discountPercent?.round();
    final photoH = height * 0.58;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: AppColors.cardSurfaceFor(theme.brightness),
        elevation: isDark ? 0 : 1,
        shadowColor: AppColors.brandBrown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushPrestataireDetail(pack.prestataireId),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: photoH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    image != null && image.isNotEmpty
                        ? AppNetworkImage(url: image, fit: BoxFit.cover)
                        : ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.local_offer_outlined,
                              size: 28,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                    if (discount != null && discount > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            DiscBoutique.discountLabel(discount),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.body,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.prestataireDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.15,
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        CurrencyFormat.eur(pack.prixPack, decimals: true),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OffersSkeleton extends StatelessWidget {
  const _OffersSkeleton({
    required this.listHeight,
    required this.cardWidth,
  });

  final double listHeight;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final track = DiscoveryShimmer.colors(Theme.of(context)).track;
    return DiscoveryShimmer.wrap(
      context: context,
      child: SizedBox(
        height: listHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, __) => Container(
            width: cardWidth,
            height: listHeight,
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
