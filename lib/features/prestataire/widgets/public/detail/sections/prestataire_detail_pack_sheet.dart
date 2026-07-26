import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/pack_item.dart';
import '../../../../../../core/models/domain/catalog/pack_item_type.dart';
import '../../../../../../core/models/domain/catalog/pack_offre_detail.dart';
import '../../../../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../../../../core/models/domain/catalog/service_beaute.dart';
import '../../../../../../router/navigation_extensions.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/utils/currency_format.dart';
import '../../../../../../shared/widgets/app/app_network_image.dart';
import '../../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../../cart/providers/boutique_cart_provider.dart';

sealed class _PackSheetResult {
  const _PackSheetResult();
}

class _PackSheetBook extends _PackSheetResult {
  const _PackSheetBook();
}

class _PackSheetSnack extends _PackSheetResult {
  const _PackSheetSnack({required this.message, required this.success});
  final String message;
  final bool success;
}

/// Bottom sheet : détail d’un pack (contenu, prix, actions).
Future<void> showPrestatairePackDetailSheet(
  BuildContext context, {
  required PackOffreDetail detail,
  required List<ServiceBeaute> services,
  required List<ProduitBoutique> produits,
  String? prestataireName,
  bool canShop = true,
}) async {
  final result = await showModalBottomSheet<_PackSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => PrestataireDetailPackSheet(
      detail: detail,
      services: services,
      produits: produits,
      prestataireName: prestataireName,
      canShop: canShop,
    ),
  );
  if (!context.mounted || result == null) return;
  switch (result) {
    case _PackSheetBook():
      context.pushBooking(
        prestataireId: detail.pack.prestataireId,
        packId: detail.pack.id,
      );
    case _PackSheetSnack(:final message, :final success):
      if (success) {
        AppSnackBar.success(context, message);
      } else {
        AppSnackBar.info(context, message);
      }
  }
}

class PrestataireDetailPackSheet extends ConsumerWidget {
  const PrestataireDetailPackSheet({
    super.key,
    required this.detail,
    required this.services,
    required this.produits,
    this.prestataireName,
    this.canShop = true,
  });

  final PackOffreDetail detail;
  final List<ServiceBeaute> services;
  final List<ProduitBoutique> produits;
  final String? prestataireName;
  final bool canShop;

  void _bookPack(BuildContext context) {
    final hasServices =
        detail.items.any((i) => i.itemType == PackItemType.service);
    if (!hasServices) {
      AppSnackBar.info(context, DiscBoutique.packBookingNoServiceBody);
      return;
    }
    Navigator.of(context).pop(const _PackSheetBook());
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
      Navigator.of(context).pop(
        const _PackSheetSnack(
          message: DiscBoutique.cartAddOutOfStock,
          success: false,
        ),
      );
      return;
    }
    final message = last == BoutiqueCartAddResult.clampedToStock
        ? DiscBoutique.cartStockMaxReached
        : last == BoutiqueCartAddResult.switchedPrestataire
            ? DiscBoutique.cartSwitchedPresta
            : DiscBoutique.cartAdded;
    final success = last != BoutiqueCartAddResult.clampedToStock;
    Navigator.of(context).pop(
      _PackSheetSnack(message: message, success: success),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pack = detail.pack;
    final discount = detail.discountPercent?.round();
    final servicesById = {for (final s in services) s.id: s};
    final produitsById = {for (final p in produits) p.id: p};
    final hasServices =
        detail.items.any((i) => i.itemType == PackItemType.service);
    final hasProducts =
        detail.items.any((i) => i.itemType == PackItemType.produit);
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    final pad = DiscoveryResponsive.of(context).horizontalPadding;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, 0, pad, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (pack.imageUrl?.trim().isNotEmpty == true) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: AppNetworkImage(
                            url: pack.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (pack.isOffreDuJour)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          DiscBoutique.badgeOffreDuJour,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Text(
                      pack.titre,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    if (pack.description?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        pack.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _PackPriceBlock(
                      prixPack: pack.prixPack,
                      prixCatalogue: detail.prixCatalogue,
                      discountPercent: discount,
                    ),
                    if (hasServices && hasProducts) ...[
                      const SizedBox(height: 10),
                      Text(
                        DiscBoutique.packMixedHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      DiscBoutique.packContentsTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (detail.items.isEmpty)
                      Text(
                        DiscBoutique.packItemUnavailable,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      )
                    else
                      for (final item in detail.items) ...[
                        _PackContentRow(
                          item: item,
                          service: item.serviceId == null
                              ? null
                              : servicesById[item.serviceId],
                          produit: item.produitId == null
                              ? null
                              : produitsById[item.produitId],
                        ),
                        const SizedBox(height: 8),
                      ],
                  ],
                ),
              ),
            ),
            if (canShop && (hasServices || hasProducts)) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasServices)
                    FilledButton(
                      onPressed: () => _bookPack(context),
                      child: const Text(DiscBoutique.packBookServices),
                    )
                  else if (hasProducts)
                    OutlinedButton(
                      onPressed: () => _addProducts(context, ref),
                      child: const Text(DiscBoutique.packAddProducts),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PackPriceBlock extends StatelessWidget {
  const _PackPriceBlock({
    required this.prixPack,
    required this.prixCatalogue,
    this.discountPercent,
  });

  final double prixPack;
  final double prixCatalogue;
  final int? discountPercent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSaving = prixCatalogue > prixPack;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasSaving) ...[
            Text(
              DiscBoutique.packPrixCatalogue,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            Text(
              CurrencyFormat.eur(prixCatalogue, decimals: true),
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            DiscBoutique.packPrixPack,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Text(
                  CurrencyFormat.eur(prixPack, decimals: true),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              if (discountPercent != null && discountPercent! > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    DiscBoutique.discountLabel(discountPercent!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PackContentRow extends StatelessWidget {
  const _PackContentRow({
    required this.item,
    this.service,
    this.produit,
  });

  final PackItem item;
  final ServiceBeaute? service;
  final ProduitBoutique? produit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isService = item.itemType == PackItemType.service;
    final title = isService
        ? (service?.nom.trim().isNotEmpty == true
            ? service!.nom
            : DiscBoutique.packItemUnavailable)
        : (produit?.nom.trim().isNotEmpty == true
            ? produit!.nom
            : DiscBoutique.packItemUnavailable);
    final unitPrice = isService ? service?.prix : produit?.prix;
    final subtitleParts = <String>[
      isService ? DiscBoutique.packItemService : DiscBoutique.packItemProduit,
      DiscBoutique.packItemQty(item.quantite),
      if (isService && service != null)
        DiscBoutique.packServiceDuration(service!.dureeMinutes),
      if (!isService && produit?.conditionnement?.trim().isNotEmpty == true)
        produit!.conditionnement!.trim(),
    ];
    final outOfStock = !isService && produit != null && produit!.isOutOfStock;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isService ? Icons.spa_outlined : Icons.shopping_bag_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleParts.join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                if (outOfStock)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      DiscBoutique.stockOutClient,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (unitPrice != null)
            Text(
              CurrencyFormat.eur(unitPrice * item.quantite, decimals: true),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
