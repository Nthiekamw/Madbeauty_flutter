import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/pack_item_type.dart';
import '../../../../../../core/models/domain/catalog/pack_offre_detail.dart';
import '../../../../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../../../../core/models/domain/catalog/service_beaute.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/utils/currency_format.dart';
import '../../../../../../shared/widgets/app/app_network_image.dart';
import '../../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../../cart/providers/boutique_cart_provider.dart';
import '../../../../providers/boutique/boutique_providers.dart';
import '../../../../providers/profile/prestataire_services_provider.dart';
import 'prestataire_detail_empty_state.dart';
import 'prestataire_detail_pack_sheet.dart';
import 'prestataire_detail_produit_sheet.dart';
import 'prestataire_detail_section_layout.dart';

/// Onglet Boutique + Offres sur la fiche publique prestataire.
class PrestataireDetailBoutiqueBlock extends ConsumerWidget {
  const PrestataireDetailBoutiqueBlock({
    super.key,
    required this.prestataireId,
    this.prestataireName,
    this.canShop = true,
  });

  final String prestataireId;
  final String? prestataireName;
  final bool canShop;

  static ButtonStyle _compactBtn(ThemeData theme) {
    return ButtonStyle(
      visualDensity: VisualDensity.compact,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(0, 30)),
      textStyle: WidgetStatePropertyAll(
        theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final produitsAsync =
        ref.watch(publicProduitsBoutiqueProvider(prestataireId));
    final packsAsync =
        ref.watch(publicPacksOffreDetailProvider(prestataireId));
    final servicesAsync = ref.watch(servicesProvider(prestataireId));
    final cartCount = ref.watch(boutiqueCartItemCountProvider);
    final services = servicesAsync.asData?.value ?? const <ServiceBeaute>[];
    final btn = _compactBtn(theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireDetailSectionCard(
          icon: Icons.storefront_outlined,
          title: DiscBoutique.clientBoutiqueTitle,
          trailing: cartCount > 0
              ? TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => context.pushClientCart(),
                  child: Text(
                    '${DiscBoutique.actionViewCart} (${DiscBoutique.cartBadge(cartCount)})',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              : null,
          child: produitsAsync.when(
            loading: () => const _BoutiqueShimmer(),
            error: (_, __) => DiscoverySectionError(
              message: DiscBoutique.boutiqueLoadErr,
              onRetry: () => ref.invalidate(
                publicProduitsBoutiqueProvider(prestataireId),
              ),
            ),
            data: (produits) {
              if (produits.isEmpty) {
                return const PrestataireDetailEmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: DiscBoutique.clientBoutiqueEmptyTitle,
                  body: DiscBoutique.clientBoutiqueEmptyBody,
                );
              }
              return _BoutiqueHorizontalStrip(
                itemCount: produits.length,
                itemBuilder: (context, i) => _PublicProduitCard(
                  produit: produits[i],
                  prestataireName: prestataireName,
                  canShop: canShop,
                  buttonStyle: btn,
                  compact: produits.length > 1,
                ),
              );
            },
          ),
        ),
        PrestataireDetailSectionCard(
          icon: Icons.local_offer_outlined,
          title: DiscBoutique.clientPacksTitle,
          child: packsAsync.when(
            loading: () => const _BoutiqueShimmer(),
            error: (_, __) => DiscoverySectionError(
              message: DiscBoutique.packsLoadErr,
              onRetry: () => ref.invalidate(
                publicPacksOffreDetailProvider(prestataireId),
              ),
            ),
            data: (packs) {
              if (packs.isEmpty) {
                return const PrestataireDetailEmptyState(
                  icon: Icons.local_offer_outlined,
                  title: DiscBoutique.clientPacksEmptyTitle,
                  body: DiscBoutique.clientPacksEmptyBody,
                );
              }
              final produits = produitsAsync.asData?.value ?? const [];
              return _BoutiqueHorizontalStrip(
                itemCount: packs.length,
                itemBuilder: (context, i) => _PublicPackCard(
                  detail: packs[i],
                  services: services,
                  produits: produits,
                  prestataireName: prestataireName,
                  canShop: canShop,
                  buttonStyle: btn,
                  compact: packs.length > 1,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Liste horizontale si plusieurs items, sinon carte pleine largeur.
class _BoutiqueHorizontalStrip extends StatelessWidget {
  const _BoutiqueHorizontalStrip({
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  static const _listHeight = 212.0;
  static const _listHeightWeb = 228.0;
  static const _cardWidth = 148.0;
  static const _cardWidthWeb = 160.0;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) {
      return itemBuilder(context, 0);
    }
    final web = DiscoveryResponsive.of(context).useWebSiteLayout;
    final listHeight = web ? _listHeightWeb : _listHeight;
    final cardWidth = web ? _cardWidthWeb : _cardWidth;
    return SizedBox(
      height: listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SizedBox(
            width: cardWidth,
            child: itemBuilder(context, index),
          );
        },
      ),
    );
  }
}

class _PublicProduitCard extends ConsumerWidget {
  const _PublicProduitCard({
    required this.produit,
    required this.buttonStyle,
    this.prestataireName,
    this.canShop = true,
    this.compact = false,
  });

  final ProduitBoutique produit;
  final ButtonStyle buttonStyle;
  final String? prestataireName;
  final bool canShop;
  final bool compact;

  Future<void> _openDetail(BuildContext context) {
    return showPrestataireProduitDetailSheet(
      context,
      produit: produit,
      prestataireName: prestataireName,
      canShop: canShop,
    );
  }

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    if (produit.isOutOfStock) {
      AppSnackBar.info(context, DiscBoutique.cartAddOutOfStock);
      return;
    }
    final result = await ref.read(boutiqueCartProvider.notifier).addProduit(
          produit: produit,
          prestataireName: prestataireName,
        );
    if (!context.mounted) return;
    if (result == BoutiqueCartAddResult.outOfStock) {
      AppSnackBar.info(context, DiscBoutique.cartAddOutOfStock);
      return;
    }
    if (result == BoutiqueCartAddResult.clampedToStock) {
      AppSnackBar.info(context, DiscBoutique.cartStockMaxReached);
      return;
    }
    AppSnackBar.success(
      context,
      result == BoutiqueCartAddResult.switchedPrestataire
          ? DiscBoutique.cartSwitchedPresta
          : DiscBoutique.cartAdded,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final image = produit.imageUrl?.trim();
    final canAdd = canShop && produit.isInStock;

    if (compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.14),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: image != null && image.isNotEmpty
                          ? AppNetworkImage(url: image, fit: BoxFit.cover)
                          : ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    produit.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  if (produit.isOutOfStock)
                    Text(
                      DiscBoutique.stockOutClient,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormat.eur(produit.prix, decimals: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (canShop) ...[
                    const SizedBox(height: 4),
                    FilledButton.tonal(
                      style: buttonStyle,
                      onPressed: canAdd ? () => _addToCart(context, ref) : null,
                      child: const Text(DiscBoutique.actionAjouter),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: image != null && image.isNotEmpty
                      ? AppNetworkImage(url: image, fit: BoxFit.cover)
                      : ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 22,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produit.nom,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      DiscBoutique.produitSeeDetailsHint,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (produit.conditionnement?.trim().isNotEmpty == true)
                      Text(
                        produit.conditionnement!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    if (produit.isOutOfStock)
                      Text(
                        DiscBoutique.stockOutClient,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else if (produit.isLowStock)
                      Text(
                        DiscBoutique.stockLowClient,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            CurrencyFormat.eur(produit.prix, decimals: true),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (canShop) ...[
                          const SizedBox(width: 8),
                          FilledButton.tonal(
                            style: buttonStyle,
                            onPressed:
                                canAdd ? () => _addToCart(context, ref) : null,
                            child: const Text(DiscBoutique.actionAjouter),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicPackCard extends ConsumerWidget {
  const _PublicPackCard({
    required this.detail,
    required this.services,
    required this.produits,
    required this.buttonStyle,
    this.prestataireName,
    this.canShop = true,
    this.compact = false,
  });

  final PackOffreDetail detail;
  final List<ServiceBeaute> services;
  final List<ProduitBoutique> produits;
  final ButtonStyle buttonStyle;
  final String? prestataireName;
  final bool canShop;
  final bool compact;

  Future<void> _openDetail(BuildContext context) {
    return showPrestatairePackDetailSheet(
      context,
      detail: detail,
      services: services,
      produits: produits,
      prestataireName: prestataireName,
      canShop: canShop,
    );
  }

  Future<void> _bookPack(BuildContext context) async {
    final hasServices =
        detail.items.any((i) => i.itemType == PackItemType.service);
    if (!hasServices) {
      AppSnackBar.info(context, DiscBoutique.packBookingNoServiceBody);
      return;
    }
    context.pushBooking(
      prestataireId: detail.pack.prestataireId,
      packId: detail.pack.id,
    );
  }

  Future<void> _addProducts(BuildContext context, WidgetRef ref) async {
    final produitsById = {for (final p in produits) p.id: p};
    var added = 0;
    BoutiqueCartAddResult? last;
    for (final item in detail.items) {
      if (item.itemType != PackItemType.produit) continue;
      final id = item.produitId;
      if (id == null) continue;
      final produit = produitsById[id];
      if (produit == null || produit.isOutOfStock) continue;
      last = await ref.read(boutiqueCartProvider.notifier).addProduit(
            produit: produit,
            prestataireName: prestataireName,
            quantite: item.quantite,
          );
      if (last == BoutiqueCartAddResult.outOfStock) continue;
      added++;
    }
    if (!context.mounted) return;
    if (added == 0) {
      AppSnackBar.info(context, DiscBoutique.cartAddOutOfStock);
      return;
    }
    if (last == BoutiqueCartAddResult.clampedToStock) {
      AppSnackBar.info(context, DiscBoutique.cartStockMaxReached);
      return;
    }
    AppSnackBar.success(
      context,
      last == BoutiqueCartAddResult.switchedPrestataire
          ? DiscBoutique.cartSwitchedPresta
          : DiscBoutique.cartAdded,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pack = detail.pack;
    final discount = detail.discountPercent?.round();
    final hasServices =
        detail.items.any((i) => i.itemType == PackItemType.service);
    final hasProducts =
        detail.items.any((i) => i.itemType == PackItemType.produit);
    final image = pack.imageUrl?.trim();

    if (compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.14),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 6),
                  if (pack.isOffreDuJour)
                    Text(
                      DiscBoutique.badgeOffreDuJour,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  Text(
                    pack.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          CurrencyFormat.eur(pack.prixPack, decimals: true),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      if (discount != null && discount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          DiscBoutique.discountLabel(discount),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (canShop && (hasServices || hasProducts)) ...[
                    const SizedBox(height: 4),
                    if (hasServices)
                      FilledButton(
                        style: buttonStyle,
                        onPressed: () => _bookPack(context),
                        child: const Text(DiscBoutique.packBookServicesShort),
                      )
                    else
                      OutlinedButton(
                        style: buttonStyle,
                        onPressed: () => _addProducts(context, ref),
                        child: const Text(DiscBoutique.packAddProductsShort),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pack.isOffreDuJour)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    DiscBoutique.badgeOffreDuJour,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image != null && image.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: AppNetworkImage(url: image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pack.titre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          DiscBoutique.packSeeDetailsHint,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                ],
              ),
              if (hasServices && hasProducts)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DiscBoutique.packMixedHint,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (detail.prixCatalogue > pack.prixPack) ...[
                    Text(
                      CurrencyFormat.eur(detail.prixCatalogue, decimals: true),
                      style: theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      CurrencyFormat.eur(pack.prixPack, decimals: true),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (discount != null && discount > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      DiscBoutique.discountLabel(discount),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
              if (canShop && (hasServices || hasProducts)) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (hasServices)
                      FilledButton(
                        style: buttonStyle,
                        onPressed: () => _bookPack(context),
                        child: const Text(DiscBoutique.packBookServicesShort),
                      )
                    else if (hasProducts)
                      OutlinedButton(
                        style: buttonStyle,
                        onPressed: () => _addProducts(context, ref),
                        child: const Text(DiscBoutique.packAddProductsShort),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BoutiqueShimmer extends StatelessWidget {
  const _BoutiqueShimmer();

  @override
  Widget build(BuildContext context) {
    final track = DiscoveryShimmer.colors(Theme.of(context)).track;
    return DiscoveryShimmer.wrap(
      context: context,
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, __) => Container(
            width: 140,
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
