import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/utils/currency_format.dart';
import '../../../../../../shared/widgets/app/app_network_image.dart';
import '../../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../../auth/providers/auth_notifier.dart';
import '../../../../../cart/providers/boutique_cart_provider.dart';
import '../../../../../wishlist/providers/client_wishlist_product_ids_provider.dart';
import '../../../../../../router/navigation_extensions.dart';

/// Bottom sheet : détail d’un produit boutique.
Future<void> showPrestataireProduitDetailSheet(
  BuildContext context, {
  required ProduitBoutique produit,
  String? prestataireName,
  bool canShop = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => PrestataireDetailProduitSheet(
      produit: produit,
      prestataireName: prestataireName,
      canShop: canShop,
    ),
  );
}

class PrestataireDetailProduitSheet extends ConsumerWidget {
  const PrestataireDetailProduitSheet({
    super.key,
    required this.produit,
    this.prestataireName,
    this.canShop = true,
  });

  final ProduitBoutique produit;
  final String? prestataireName;
  final bool canShop;

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
    final message = result == BoutiqueCartAddResult.clampedToStock
        ? DiscBoutique.cartStockMaxReached
        : result == BoutiqueCartAddResult.switchedPrestataire
            ? DiscBoutique.cartSwitchedPresta
            : DiscBoutique.cartAdded;
    final success = result != BoutiqueCartAddResult.clampedToStock;
    Navigator.of(context).pop();
    if (!context.mounted) return;
    if (success) {
      AppSnackBar.success(context, message);
    } else {
      AppSnackBar.info(context, message);
    }
  }

  Future<void> _toggleWishlist(BuildContext context, WidgetRef ref) async {
    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) {
      AppSnackBar.show(context, message: DiscWishlist.loginRequired);
      context.pushLogin();
      return;
    }

    final wasInWishlist =
        ref.read(isProduitInWishlistProvider(produit.id));
    try {
      await ref.read(clientWishlistProductIdsProvider.notifier).toggle(
            produit.id,
            lastSeenPrice: produit.prix,
          );
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: wasInWishlist
            ? DiscWishlist.removedFeedback
            : DiscWishlist.addedFeedback,
      );
    } catch (_) {
      if (!context.mounted) return;
      AppSnackBar.show(context, message: DiscWishlist.toggleError);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final image = produit.imageUrl?.trim();
    final pad = DiscoveryResponsive.of(context).horizontalPadding;
    final maxH = MediaQuery.sizeOf(context).height * 0.88;
    final canAdd = canShop && produit.isInStock;
    final inWishlist = ref.watch(isProduitInWishlistProvider(produit.id));

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
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 16 / 10,
                            child: image != null && image.isNotEmpty
                                ? AppNetworkImage(
                                    url: image,
                                    fit: BoxFit.cover,
                                  )
                                : ColoredBox(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 48,
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: AppColors.scrimDark38,
                            shape: CircleBorder(
                              side: BorderSide(
                                color: inWishlist
                                    ? AppColors.onPrimarySurface50
                                    : AppColors.onPrimarySurface28,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () => _toggleWishlist(context, ref),
                              customBorder: const CircleBorder(),
                              child: Tooltip(
                                message: inWishlist
                                    ? DiscWishlist.removeTooltip
                                    : DiscWishlist.addTooltip,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    inWishlist
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 22,
                                    color: inWishlist
                                        ? AppColors.favorite
                                        : AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      produit.nom,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          DiscBoutique.categorieLabel(produit.categorie.dbValue),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (produit.conditionnement?.trim().isNotEmpty == true)
                          Text(
                            produit.conditionnement!,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                      ],
                    ),
                    if (produit.description?.trim().isNotEmpty == true) ...[
                      const SizedBox(height: 10),
                      Text(
                        produit.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              CurrencyFormat.eur(produit.prix, decimals: true),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          if (produit.isOutOfStock)
                            Text(
                              DiscBoutique.stockOutClient,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          else if (produit.isLowStock)
                            Text(
                              DiscBoutique.stockLowClient,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else if (!produit.stockIllimite)
                            Text(
                              DiscBoutique.stockBadgeQty(produit.stockQty),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (canShop) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: canAdd ? () => _addToCart(context, ref) : null,
                child: const Text(DiscBoutique.actionAddToCart),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
