import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/boutique_commande.dart';
import '../../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../providers/boutique/boutique_providers.dart';
import '../providers/profile/current_prestataire_provider.dart';
import '../widgets/workspace/prestataire_flow_scaffold.dart';

/// Liste et suivi des commandes boutique (espace prestataire).
class PrestataireBoutiqueOrdersScreen extends ConsumerWidget {
  const PrestataireBoutiqueOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ownBoutiqueCommandesProvider);

    return PrestataireSubpageScaffold(
      title: DiscBoutique.ordersTitle,
      subtitle: DiscBoutique.ordersSubtitle,
      icon: Icons.receipt_long_outlined,
      body: async.when(
        loading: () => const DiscoveryListSkeleton(rowCount: 4, rowHeight: 120),
        error: (_, __) => DiscoveryEmptyState(
          icon: Icons.cloud_off_outlined,
          title: DiscBoutique.ordersLoadErr,
          body: CoreStrings.networkErrorBody,
          actionLabel: DiscList.retry,
          onAction: () => ref.invalidate(ownBoutiqueCommandesProvider),
        ),
        data: (commandes) {
          if (commandes.isEmpty) {
            return const DiscoveryEmptyState(
              icon: Icons.receipt_long_outlined,
              title: DiscBoutique.ordersEmptyTitle,
              body: DiscBoutique.ordersEmptyBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ownBoutiqueCommandesProvider);
              ref.invalidate(ownBoutiqueOrdersOpenCountProvider);
              await ref.read(ownBoutiqueCommandesProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: commandes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _CommandeCard(commande: commandes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CommandeCard extends ConsumerStatefulWidget {
  const _CommandeCard({required this.commande});

  final BoutiqueCommande commande;

  @override
  ConsumerState<_CommandeCard> createState() => _CommandeCardState();
}

class _CommandeCardState extends ConsumerState<_CommandeCard> {
  bool _busy = false;

  String _statutLabel(BoutiqueCommandeStatut s) => switch (s) {
        BoutiqueCommandeStatut.pendingPayment =>
          DiscBoutique.statutPendingPayment,
        BoutiqueCommandeStatut.payOnSite => DiscBoutique.statutPayOnSite,
        BoutiqueCommandeStatut.paid => DiscBoutique.statutPaid,
        BoutiqueCommandeStatut.preparing => DiscBoutique.statutPreparing,
        BoutiqueCommandeStatut.ready => DiscBoutique.statutReady,
        BoutiqueCommandeStatut.completed => DiscBoutique.statutCompleted,
        BoutiqueCommandeStatut.canceled => DiscBoutique.statutCanceled,
      };

  Future<void> _advance() async {
    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(boutiqueCommandeServiceProvider);
    if (presta == null || service == null) return;
    setState(() => _busy = true);
    try {
      await service.advanceStatut(
        prestataireId: presta.id,
        commande: widget.commande,
      );
      ref.invalidate(ownBoutiqueCommandesProvider);
      ref.invalidate(ownBoutiqueOrdersOpenCountProvider);
      if (mounted) {
        AppSnackBar.success(context, DiscBoutique.ordersUpdated);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscBoutique.ordersUpdateErr);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final presta = await ref.read(currentPrestataireProvider.future);
    final service = ref.read(boutiqueCommandeServiceProvider);
    if (presta == null || service == null) return;
    setState(() => _busy = true);
    try {
      await service.cancel(
        prestataireId: presta.id,
        commandeId: widget.commande.id,
      );
      ref.invalidate(ownBoutiqueCommandesProvider);
      ref.invalidate(ownBoutiqueOrdersOpenCountProvider);
      if (mounted) {
        AppSnackBar.success(context, DiscBoutique.ordersCanceled);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscBoutique.ordersUpdateErr);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.commande;
    final dateLabel = DateFormat.yMMMd('fr_FR').add_Hm().format(
          c.createdAt.toLocal(),
        );
    final next = c.statut.nextForPrestataire;
    final client =
        c.clientDisplayName?.trim().isNotEmpty == true
            ? c.clientDisplayName!
            : DiscBoutique.ordersUnknownClient;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  client,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statutLabel(c.statut),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in c.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '${item.quantite}× ${item.nomSnapshot}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormat.eur(c.amountEuros, decimals: true),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
          if (next != null || c.statut.isOpen) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (next != null)
                  FilledButton(
                    onPressed: _busy ? null : _advance,
                    child: Text(
                      DiscBoutique.nextActionLabel(c.statut.dbValue),
                    ),
                  ),
                if (c.statut.isOpen &&
                    c.statut != BoutiqueCommandeStatut.completed) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _busy ? null : _cancel,
                    child: const Text(DiscBoutique.ordersActionCancel),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
