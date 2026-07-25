import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../providers/boutique/boutique_providers.dart';
import '../../shared/prestataire_section_header.dart';
import '../layout/prestataire_dashboard_insets.dart';

/// Raccourcis Boutique + Packs sur le dashboard prestataire.
class PrestataireDashboardBoutiqueCard extends ConsumerWidget {
  const PrestataireDashboardBoutiqueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(ownBoutiqueSummaryProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: PrestataireDashboardInsets.page(context).copyWith(
        top: 4,
        bottom: 8,
      ),
      child: DiscoverySurfaceCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrestataireSectionHeader(
              icon: Icons.storefront_rounded,
              title: DiscBoutique.dashSectionTitle,
              subtitle: DiscBoutique.dashSectionSubtitle,
              iconColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            summaryAsync.when(
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (_, __) => Text(
                DiscBoutique.dashEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              data: (summary) {
                final empty =
                    summary.produitsActifs == 0 && summary.packsActifs == 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatChip(
                            label: DiscBoutique.dashProduits,
                            value: '${summary.produitsActifs}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatChip(
                            label: DiscBoutique.dashPacks,
                            value: '${summary.packsActifs}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatChip(
                            label: DiscBoutique.dashOrdersOpen,
                            value: '${summary.commandesOuvertes}',
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
                          onPressed: () =>
                              context.pushPrestataireBoutiqueOrders(),
                          child: const Text(DiscBoutique.dashManageOrders),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
