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

/// Section accueil « Offres spéciales près de vous » (cartes horizontales).
class ClientHomeOffersSection extends ConsumerWidget {
  const ClientHomeOffersSection({super.key});

  static const double _listHeight = 124;
  static const double _listHeightWeb = 132;
  static const double _cardWidth = 312;
  static const double _cardWidthWeb = 360;

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
          actionLabel: DiscHome.offersSeeAll,
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
                separatorBuilder: (_, __) => const SizedBox(width: 10),
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

  void _openDetail(BuildContext context) {
    context.pushPrestataireDetail(entry.pack.prestataireId);
  }

  void _onBook(BuildContext context) {
    if (entry.hasBookableServices) {
      context.pushBooking(
        prestataireId: entry.pack.prestataireId,
        packId: entry.pack.id,
      );
      return;
    }
    _openDetail(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pack = entry.pack;
    final image = pack.imageUrl?.trim();
    final discount = entry.discountPercent?.round();
    final catalogue = entry.prixCatalogue;
    final showStrike =
        catalogue != null && catalogue > pack.prixPack + 0.009;
    final subtitle = entry.itemsSummary?.trim();
    final primary = theme.colorScheme.primary;
    // Image un peu plus compacte pour laisser place au texte + CTA.
    final thumb = (height - 28).clamp(64.0, 88.0);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: AppColors.cardSurfaceFor(theme.brightness),
        elevation: isDark ? 0 : 1,
        shadowColor: AppColors.brandBrown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: thumb,
                    height: thumb,
                    child: image != null && image.isNotEmpty
                        ? AppNetworkImage(url: image, fit: BoxFit.cover)
                        : ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.local_offer_outlined,
                              size: 28,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (pack.isOffreDuJour) ...[
                        _OffreDuJourBadge(primary: primary),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        pack.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFamily: AppFonts.body,
                          height: 1.15,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showStrike) ...[
                              Text(
                                CurrencyFormat.eur(catalogue, decimals: true),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.colorScheme.outline,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              CurrencyFormat.eur(pack.prixPack, decimals: true),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: primary,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (discount != null && discount > 0) ...[
                        const SizedBox(height: 4),
                        _DiscountPill(
                          label: DiscBoutique.discountLabel(discount),
                          primary: primary,
                        ),
                      ],
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 32,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () => _onBook(context),
                            child: const Text(
                              DiscBoutique.packBookServicesShort,
                            ),
                          ),
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
    );
  }
}

class _OffreDuJourBadge extends StatelessWidget {
  const _OffreDuJourBadge({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 12,
                color: primary,
              ),
              const SizedBox(width: 3),
              Text(
                DiscBoutique.badgeOffreDuJour,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscountPill extends StatelessWidget {
  const _DiscountPill({required this.label, required this.primary});

  final String label;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: primary,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          height: 1.1,
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
          itemCount: 2,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => Container(
            width: cardWidth,
            height: listHeight,
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
