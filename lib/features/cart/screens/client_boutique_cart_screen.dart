import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/stripe_platform_policy.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/stripe/stripe_payment_exception.dart';
import '../../../services/stripe/stripe_payment_providers.dart';
import '../../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_network_image.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../booking/widgets/confirmation/booking_web_payment_dialog.dart';
import '../../prestataire/providers/boutique/boutique_providers.dart'
    show publicProduitsBoutiqueProvider;
import '../providers/boutique_cart_provider.dart';
import '../providers/client_boutique_commandes_provider.dart';

/// Écran panier boutique client.
class ClientBoutiqueCartScreen extends ConsumerStatefulWidget {
  const ClientBoutiqueCartScreen({super.key});

  @override
  ConsumerState<ClientBoutiqueCartScreen> createState() =>
      _ClientBoutiqueCartScreenState();
}

class _ClientBoutiqueCartScreenState
    extends ConsumerState<ClientBoutiqueCartScreen> {
  bool _submitting = false;

  Future<void> _checkout({required bool payOnSite}) async {
    var cart = ref.read(boutiqueCartProvider);
    if (cart.isEmpty) return;

    final user = ref.read(authNotifierProvider).asData?.value;
    final isGuest = ref.read(isGuestBrowsingProvider);
    if (user == null || isGuest) {
      AppSnackBar.info(context, DiscBoutique.cartCheckoutGuest);
      context.pushLogin();
      return;
    }

    setState(() => _submitting = true);
    try {
      final commandeSvc = ref.read(boutiqueCommandeServiceProvider);
      if (commandeSvc != null) {
        final revalidated = await commandeSvc.revalidateCart(cart);
        await ref
            .read(boutiqueCartProvider.notifier)
            .replaceWith(revalidated.cart);
        cart = revalidated.cart;
        if (!mounted) return;
        if (cart.isEmpty) {
          AppSnackBar.info(context, DiscBoutique.cartRevalidateEmpty);
          return;
        }
        if (revalidated.hasChanges) {
          final msg = revalidated.removedNames.isNotEmpty
              ? DiscBoutique.cartRevalidateRemoved
              : revalidated.quantitiesReduced
                  ? DiscBoutique.cartRevalidateStockReduced
                  : DiscBoutique.cartRevalidatePrices;
          AppSnackBar.info(context, msg);
        }
      }

      if (!payOnSite && StripePlatformPolicy.isEnabled) {
        final stripeSvc = ref.read(stripeBoutiquePaymentServiceProvider);
        if (stripeSvc == null) {
          AppSnackBar.error(context, DiscBoutique.cartCheckoutErr);
          return;
        }
        final sheet = await stripeSvc.createPaymentIntent(cart: cart);
        if (!mounted) return;
        await showBookingWebPaymentDialog(
          context,
          sheet: sheet,
          amountLabel: CurrencyFormat.eur(
            sheet.amountCents / 100,
            decimals: true,
          ),
        );
        await stripeSvc.markCommandePaidByIntent(sheet.paymentIntentId);
        await ref.read(boutiqueCartProvider.notifier).clear();
        if (!mounted) return;
        AppSnackBar.success(context, DiscBoutique.cartCheckoutSuccessPaid);
        ref.invalidate(clientBoutiqueCommandesProvider);
        context.pushClientBoutiqueOrders();
        return;
      }

      final service = ref.read(boutiqueCommandeServiceProvider);
      if (service == null) {
        AppSnackBar.error(context, DiscBoutique.cartCheckoutErr);
        return;
      }
      await service.createFromCart(cart: cart, payOnSite: true);
      await ref.read(boutiqueCartProvider.notifier).clear();
      if (!mounted) return;
      AppSnackBar.success(context, DiscBoutique.cartCheckoutSuccess);
      ref.invalidate(clientBoutiqueCommandesProvider);
      context.pushClientBoutiqueOrders();
    } on StripePaymentCanceledException {
      // Utilisateur a annulé — panier conservé.
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscBoutique.cartCheckoutErr);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(boutiqueCartProvider);
    final theme = Theme.of(context);
    final canPayOnline = StripePlatformPolicy.isEnabled;
    final prestaId = cart.prestataireId;
    final stockByProduitId = <String, int?>{};
    if (prestaId != null && prestaId.isNotEmpty) {
      final produits = ref.watch(publicProduitsBoutiqueProvider(prestaId)).asData
          ?.value;
      if (produits != null) {
        for (final p in produits) {
          stockByProduitId[p.id] = p.maxOrderableQty;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscBoutique.cartTitle),
        actions: [
          IconButton(
            tooltip: DiscBoutique.menuClientOrders,
            onPressed: () => context.pushClientBoutiqueOrders(),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: cart.isEmpty
          ? DiscoveryEmptyState(
              icon: Icons.shopping_bag_outlined,
              title: DiscBoutique.cartEmptyTitle,
              body: DiscBoutique.cartEmptyBody,
              actionLabel: DiscHome.ctaBrowseCatalog,
              onAction: () => context.goClientSearch(),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                if (cart.prestataireName?.trim().isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      cart.prestataireName!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                for (final line in cart.lines) ...[
                  DiscoverySurfaceCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: line.imageUrl?.trim().isNotEmpty == true
                                ? AppNetworkImage(
                                    url: line.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : ColoredBox(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.shopping_bag_outlined,
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
                                line.nom,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (line.conditionnement?.trim().isNotEmpty ==
                                  true)
                                Text(
                                  line.conditionnement!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyFormat.eur(
                                  line.lineTotal,
                                  decimals: true,
                                ),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _submitting
                                        ? null
                                        : () => ref
                                            .read(boutiqueCartProvider.notifier)
                                            .setQuantity(
                                              line.produitId,
                                              line.quantite - 1,
                                              maxOrderableQty:
                                                  stockByProduitId[
                                                      line.produitId],
                                            ),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text('${line.quantite}'),
                                  IconButton(
                                    onPressed: _submitting
                                        ? null
                                        : () async {
                                            final r = await ref
                                                .read(
                                                  boutiqueCartProvider.notifier,
                                                )
                                                .setQuantity(
                                                  line.produitId,
                                                  line.quantite + 1,
                                                  maxOrderableQty:
                                                      stockByProduitId[
                                                          line.produitId],
                                                );
                                            if (!context.mounted) return;
                                            if (r ==
                                                    BoutiqueCartAddResult
                                                        .clampedToStock ||
                                                r ==
                                                    BoutiqueCartAddResult
                                                        .outOfStock) {
                                              AppSnackBar.info(
                                                context,
                                                DiscBoutique.cartStockMaxReached,
                                              );
                                            }
                                          },
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (!canPayOnline)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DiscBoutique.cartPayWebOnly,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          DiscBoutique.cartTotal,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          CurrencyFormat.eur(cart.totalAmount, decimals: true),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (canPayOnline)
                      FilledButton(
                        onPressed: _submitting
                            ? null
                            : () => _checkout(payOnSite: false),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(DiscBoutique.cartCheckoutWebPay),
                      )
                    else
                      FilledButton(
                        onPressed: _submitting
                            ? null
                            : () => _checkout(payOnSite: true),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(DiscBoutique.cartCheckoutOnSite),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
