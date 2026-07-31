import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/wishlist/wishlist_providers.dart';
import '../../../services/supabase/wishlist/wishlist_service.dart';import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/profile_flow_scaffold.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_network_image.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../providers/client_wishlist_product_ids_provider.dart';

class ClientWishlistScreen extends ConsumerWidget {
  const ClientWishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final listPadding = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 28)
        : const EdgeInsets.fromLTRB(16, 4, 16, 28);

    if (user == null || isGuest) {
      return ProfileFlowScaffold(
        title: DiscWishlist.screenTitle,
        icon: Icons.favorite_border_rounded,
        wrapPanel: false,
        body: GuestAccountPrompt(
          icon: Icons.favorite_border_rounded,
          title: DiscWishlist.screenTitle,
          message: DiscWishlist.loginRequired,
        ),
      );
    }

    ref.listen(clientWishlistProductIdsProvider, (previous, next) {
      final prevIds = previous?.asData?.value;
      final nextIds = next.asData?.value;
      if (prevIds != nextIds) {
        ref.invalidate(clientWishlistEntriesProvider);
      }
    });

    final entriesAsync = ref.watch(clientWishlistEntriesProvider);

    return ProfileFlowScaffold(
      title: DiscWishlist.screenTitle,
      icon: Icons.favorite_border_rounded,
      body: entriesAsync.when(
        loading: () => const DiscoveryListSkeleton(rowCount: 5, rowHeight: 120),
        error: (_, __) => Center(
          child: DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: DiscWishlist.loadErrorTitle,
            body: DiscWishlist.loadErrorBody,
            iconColor: theme.colorScheme.error,
            actionLabel: DiscList.retry,
            onAction: () => ref.invalidate(clientWishlistEntriesProvider),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: DiscoveryEmptyState(
                icon: Icons.favorite_border_rounded,
                title: DiscWishlist.emptyTitle,
                body: DiscWishlist.emptyBody,
                iconColor: theme.colorScheme.primary,
                actionLabel: DiscWishlist.browseAction,
                onAction: () => context.goClientSearch(),
              ),
            );
          }

          return ListView.separated(
            padding: listPadding,
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _WishlistProductCard(entry: entries[index]);
            },
          );
        },
      ),
    );
  }
}

class _WishlistProductCard extends ConsumerStatefulWidget {
  const _WishlistProductCard({required this.entry});

  final WishlistEntry entry;

  @override
  ConsumerState<_WishlistProductCard> createState() =>
      _WishlistProductCardState();
}

class _WishlistProductCardState extends ConsumerState<_WishlistProductCard> {
  late bool _alertRestock;
  late bool _alertPriceDrop;
  bool _busyAlerts = false;
  bool _busyRemove = false;

  @override
  void initState() {
    super.initState();
    _alertRestock = widget.entry.alertOnRestock;
    _alertPriceDrop = widget.entry.alertOnPriceDrop;
  }

  @override
  void didUpdateWidget(covariant _WishlistProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.produitId != widget.entry.produitId ||
        oldWidget.entry.alertOnRestock != widget.entry.alertOnRestock ||
        oldWidget.entry.alertOnPriceDrop != widget.entry.alertOnPriceDrop) {
      _alertRestock = widget.entry.alertOnRestock;
      _alertPriceDrop = widget.entry.alertOnPriceDrop;
    }
  }

  Future<void> _setAlert({
    bool? restock,
    bool? priceDrop,
  }) async {
    if (_busyAlerts) return;
    final client = await ref.read(currentClientProfileProvider.future);
    final service = ref.read(wishlistServiceProvider);
    if (client == null || service == null) return;

    final prevRestock = _alertRestock;
    final prevPrice = _alertPriceDrop;
    setState(() {
      _busyAlerts = true;
      if (restock != null) _alertRestock = restock;
      if (priceDrop != null) _alertPriceDrop = priceDrop;
    });

    try {
      await service.updateAlerts(
        clientId: client.id,
        produitId: widget.entry.produitId,
        alertOnRestock: restock,
        alertOnPriceDrop: priceDrop,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _alertRestock = prevRestock;
        _alertPriceDrop = prevPrice;
      });
      AppSnackBar.error(context, DiscWishlist.alertUpdateError);
    } finally {
      if (mounted) setState(() => _busyAlerts = false);
    }
  }

  Future<void> _remove() async {
    if (_busyRemove) return;
    final produit = widget.entry.produit;
    final price = produit?.prix ?? widget.entry.lastSeenPrice;
    setState(() => _busyRemove = true);
    try {
      await ref.read(clientWishlistProductIdsProvider.notifier).toggle(
            widget.entry.produitId,
            lastSeenPrice: price,
          );
      if (mounted) {
        AppSnackBar.show(context, message: DiscWishlist.removedFeedback);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(context, message: DiscWishlist.toggleError);
      }
    } finally {
      if (mounted) setState(() => _busyRemove = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final produit = widget.entry.produit;
    final image = produit?.imageUrl?.trim();
    final name = produit?.nom.trim().isNotEmpty == true
        ? produit!.nom
        : DiscWishlist.screenTitle;
    final price = produit?.prix ?? widget.entry.lastSeenPrice;
    final outOfStock = produit?.isOutOfStock == true;

    return DiscoverySurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormat.eur(price, decimals: true),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (outOfStock) ...[
                        const SizedBox(height: 4),
                        Text(
                          DiscWishlist.outOfStockBadge,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: DiscWishlist.removeTooltip,
                  onPressed: _busyRemove ? null : _remove,
                  icon: _busyRemove
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.favorite_rounded,
                          color: AppColors.favorite,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                DiscWishlist.alertRestock,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                DiscWishlist.alertRestockHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: _alertRestock,
              onChanged: _busyAlerts
                  ? null
                  : (v) => _setAlert(restock: v),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                DiscWishlist.alertPriceDrop,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                DiscWishlist.alertPriceDropHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: _alertPriceDrop,
              onChanged: _busyAlerts
                  ? null
                  : (v) => _setAlert(priceDrop: v),
            ),
          ],
        ),
      ),
    );
  }
}
