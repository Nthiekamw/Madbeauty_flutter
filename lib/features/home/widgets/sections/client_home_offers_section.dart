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

/// Section accueil « Offres spéciales ».
class ClientHomeOffersSection extends ConsumerWidget {
  const ClientHomeOffersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeFeaturedPacksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: DiscHome.offersTitle,
          compact: true,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(),
        ),
        const SizedBox(height: 10),
        async.when(
          loading: () => const _OffersSkeleton(),
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
              height: DiscoveryResponsive.of(context).useWebSiteLayout
                  ? 148
                  : 138,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _HomeOfferCard(entry: entries[index]);
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
  const _HomeOfferCard({required this.entry});

  final PackOffreHomeEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pack = entry.pack;
    final image = pack.imageUrl?.trim();
    final discount = entry.discountPercent?.round();
    final width = DiscoveryResponsive.of(context).useWebSiteLayout ? 300.0 : 280.0;

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.cardSurfaceFor(theme.brightness),
        elevation: isDark ? 0 : 1,
        shadowColor: AppColors.brandBrown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushPrestataireDetail(pack.prestataireId),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: image != null && image.isNotEmpty
                        ? AppNetworkImage(url: image, fit: BoxFit.cover)
                        : ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.local_offer_outlined,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pack.isOffreDuJour)
                        Text(
                          DiscBoutique.badgeOffreDuJour,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFonts.body,
                          ),
                        ),
                      Text(
                        pack.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFonts.body,
                        ),
                      ),
                      Text(
                        entry.prestataireDisplayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            CurrencyFormat.eur(pack.prixPack, decimals: true),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (discount != null && discount > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                DiscBoutique.discountLabel(discount),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            DiscBoutique.actionReserver,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _OffersSkeleton extends StatelessWidget {
  const _OffersSkeleton();

  @override
  Widget build(BuildContext context) {
    final track = DiscoveryShimmer.colors(Theme.of(context)).track;
    return DiscoveryShimmer.wrap(
      context: context,
      child: SizedBox(
        height: 138,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => Container(
            width: 280,
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
