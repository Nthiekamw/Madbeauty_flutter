import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../logic/prestataire_history_grouping.dart';
import '../providers/prestataire_agenda_provider.dart';
import '../widgets/history/prestataire_history_client_section.dart';

class PrestataireHistoryScreen extends ConsumerWidget {
  const PrestataireHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final agendaAsync = ref.watch(prestataireAgendaProvider);

    return DiscoveryBrandScaffold(
      body: agendaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: DiscPrestaAgenda.loadErr,
            body: DiscList.pullDownHint,
            iconColor: theme.colorScheme.error,
            actionLabel: DiscList.retry,
            onAction: () =>
                ref.read(prestataireAgendaProvider.notifier).reload(),
          ),
        ),
        data: (reservations) {
          final groups = groupPrestataireHistoryByClient(reservations);

          if (groups.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const DiscoveryScreenHeader(
                  title: DiscPrestaClients.pageTitle,
                  subtitle: DiscPrestaClients.pageSubtitle,
                ),
                const SizedBox(height: 24),
                DiscoveryEmptyState(
                  icon: Icons.groups_rounded,
                  title: DiscPrestaClients.emptyTitle,
                  body: DiscPrestaClients.emptyBody,
                  iconColor: theme.colorScheme.primary.withValues(alpha: 0.75),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(prestataireAgendaProvider.notifier).reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                const DiscoveryScreenHeader(
                  title: DiscPrestaClients.pageTitle,
                  subtitle: DiscPrestaClients.pageSubtitle,
                ),
                const SizedBox(height: 16),
                ...List.generate(groups.length, (index) {
                  final group = groups[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: PrestataireHistoryClientSection(
                      group: group,
                      initiallyExpanded: index == 0,
                      onReservationTap: (id) =>
                          context.pushPrestataireReservationDetail(id),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
