import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../providers/boutique/boutique_providers.dart';
import '../../shared/prestataire_section_header.dart';
import '../layout/prestataire_dashboard_insets.dart';

/// Raccourcis Boutique + Packs + commandes sur le dashboard prestataire.
class PrestataireDashboardBoutiqueCard extends ConsumerWidget {
  const PrestataireDashboardBoutiqueCard({
    super.key,
    this.hideOuterHeader = false,
    this.embedInSection = false,
  });

  /// Masque le titre (déjà affiché par la tuile dashboard repliable).
  final bool hideOuterHeader;

  /// Intégré dans une section repliable (pas de padding page ni carte externe).
  final bool embedInSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(ownBoutiqueSummaryProvider);
    final theme = Theme.of(context);

    final body = summaryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(minHeight: 2),
      ),
      error: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscBoutique.dashEmptyHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => ref.invalidate(ownBoutiqueSummaryProvider),
              child: const Text(DiscList.retry),
            ),
          ),
        ],
      ),
      data: (summary) {
        final empty =
            summary.produitsActifs == 0 && summary.packsActifs == 0;
        final hasOpenOrders = summary.commandesOuvertes > 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!hideOuterHeader) ...[
              PrestataireSectionHeader(
                icon: Icons.storefront_rounded,
                title: DiscBoutique.dashSectionTitle,
                subtitle: DiscBoutique.dashSectionSubtitle,
                iconColor: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: DiscBoutique.dashProduits,
                    value: '${summary.produitsActifs}',
                    onTap: () => context.pushPrestataireBoutique(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    label: DiscBoutique.dashPacks,
                    value: '${summary.packsActifs}',
                    onTap: () => context.pushPrestatairePacks(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    label: DiscBoutique.dashOrdersOpen,
                    value: '${summary.commandesOuvertes}',
                    emphasized: hasOpenOrders,
                    onTap: () => context.pushPrestataireBoutiqueOrders(),
                  ),
                ),
              ],
            ),
            if (empty) ...[
              const SizedBox(height: 10),
              Text(
                DiscBoutique.dashEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => context.pushPrestataireBoutique(),
                  child: const Text(DiscBoutique.dashManageBoutique),
                ),
                FilledButton.tonal(
                  onPressed: () => context.pushPrestatairePacks(),
                  child: const Text(DiscBoutique.dashManagePacks),
                ),
                FilledButton(
                  onPressed: () => context.pushPrestataireBoutiqueOrders(),
                  child: Text(
                    hasOpenOrders
                        ? DiscBoutique.dashManageOrdersOpen(
                            summary.commandesOuvertes,
                          )
                        : DiscBoutique.dashManageOrders,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (embedInSection) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
        child: body,
      );
    }

    return Padding(
      padding: PrestataireDashboardInsets.page(context).copyWith(
        top: 4,
        bottom: 8,
      ),
      child: DiscoverySurfaceCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: body,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.onTap,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = emphasized
        ? theme.colorScheme.primary.withValues(alpha: 0.14)
        : theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
          );

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w800,
                  color: emphasized ? theme.colorScheme.primary : null,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: emphasized
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: emphasized ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
