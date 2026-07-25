import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/pack_item_type.dart';
import '../../../../../../core/models/domain/catalog/pack_offre_detail.dart';
import '../../../../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../shared/utils/currency_format.dart';
import '../../../../../../shared/widgets/app/app_network_image.dart';
import '../../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../../cart/providers/boutique_cart_provider.dart';
import '../../../../providers/boutique/boutique_providers.dart';
import 'prestataire_detail_empty_state.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitsAsync =
        ref.watch(publicProduitsBoutiqueProvider(prestataireId));
    final packsAsync =
        ref.watch(publicPacksOffreDetailProvider(prestataireId));
    final cartCount = ref.watch(boutiqueCartItemCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireDetailSectionCard(
          icon: Icons.storefront_outlined,
          title: DiscBoutique.clientBoutiqueTitle,
          trailing: cartCount > 0
              ? TextButton(
                  onPressed: () => context.pushClientCart(),
                  child: Text(
                    '${DiscBoutique.actionViewCart} (${DiscBoutique.cartBadge(cartCount)})',
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
              return Column(
                children: [
                  for (var i = 0; i < produits.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _PublicProduitCard(
                      produit: produits[i],
                      prestataireName: prestataireName,
                      canShop: canShop,
                    ),
                  ],
                ],
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
              return Column(
                children: [
                  for (var i = 0; i < packs.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _PublicPackCard(
                      detail: packs[i],
                      produits: produitsAsync.asData?.value ?? const [],
                      prestataireName: prestataireName,
                      canShop: canShop,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PublicProduitCard extends ConsumerWidget {
  const _PublicProduitCard({
    required this.produit,
    this.prestataireName,
    this.canShop = true,
  });

  final ProduitBoutique produit;
  final String? prestataireName;
  final bool canShop;

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(boutiqueCartProvider.notifier).addProduit(
          produit: produit,
          prestataireName: prestataireName,
        );
    if (!context.mounted) return;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                      Icons.shopping_bag_outlined,
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
              Text(
                produit.nom,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (produit.conditionnement?.trim().isNotEmpty == true)
                Text(
                  produit.conditionnement!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              if (produit.description?.trim().isNotEmpty == true)
                Text(
                  produit.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    CurrencyFormat.eur(produit.prix, decimals: true),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (canShop)
                    FilledButton.tonalIcon(
                      onPressed: () => _addToCart(context, ref),
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                      label: const Text(DiscBoutique.actionAddToCart),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublicPackCard extends ConsumerWidget {
  const _PublicPackCard({
    required this.detail,
    required this.produits,
    this.prestataireName,
    this.canShop = true,
  });

  final PackOffreDetail detail;
  final List<ProduitBoutique> produits;
  final String? prestataireName;
  final bool canShop;

  Future<void> _bookServices(BuildContext context) async {
    final serviceIds = detail.items
        .where((i) => i.itemType == PackItemType.service)
        .map((i) => i.serviceId)
        .whereType<String>()
        .toList();
    if (serviceIds.length != 1) {
      AppSnackBar.info(context, DiscBoutique.packBookMultiSoon);
      return;
    }
    context.pushBooking(
      prestataireId: detail.pack.prestataireId,
      serviceId: serviceIds.first,
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
      if (produit == null) continue;
      last = await ref.read(boutiqueCartProvider.notifier).addProduit(
            produit: produit,
            prestataireName: prestataireName,
            quantite: item.quantite,
          );
      added++;
    }
    if (!context.mounted) return;
    if (added == 0) {
      AppSnackBar.info(context, DiscBoutique.clientBoutiqueEmptyBody);
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
    final serviceCount = detail.items
        .where((i) => i.itemType == PackItemType.service)
        .length;
    final canBookServices = hasServices && serviceCount == 1;

    return Container(
      padding: const EdgeInsets.all(12),
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
              padding: const EdgeInsets.only(bottom: 6),
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
              if (pack.imageUrl?.trim().isNotEmpty == true) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: AppNetworkImage(
                      url: pack.imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  pack.titre,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (pack.description?.trim().isNotEmpty == true)
            Text(
              pack.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (hasServices && hasProducts)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                DiscBoutique.packMixedHint,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          if (hasServices && !canBookServices)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                DiscBoutique.packBookMultiSoon,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          const SizedBox(height: 8),
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
                const SizedBox(width: 8),
              ],
              Text(
                CurrencyFormat.eur(pack.prixPack, decimals: true),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              if (discount != null && discount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
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
            ],
          ),
          if (canShop) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (canBookServices)
                  FilledButton(
                    onPressed: () => _bookServices(context),
                    child: const Text(DiscBoutique.packBookServices),
                  ),
                if (hasProducts)
                  OutlinedButton(
                    onPressed: () => _addProducts(context, ref),
                    child: const Text(DiscBoutique.packAddProducts),
                  ),
              ],
            ),
          ],
        ],
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
      child: Column(
        children: List.generate(
          2,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
