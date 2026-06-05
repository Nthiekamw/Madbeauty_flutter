import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../logic/prestataire_clients_grouping.dart';
import '../providers/prestataire_agenda_provider.dart';
import '../widgets/workspace/prestataire_client_row_card.dart';
import '../widgets/workspace/prestataire_profile_completion_card.dart';
import '../widgets/workspace/prestataire_workspace_shell.dart';

class PrestataireHistoryScreen extends ConsumerStatefulWidget {
  const PrestataireHistoryScreen({super.key});

  @override
  ConsumerState<PrestataireHistoryScreen> createState() =>
      _PrestataireHistoryScreenState();
}

class _PrestataireHistoryScreenState
    extends ConsumerState<PrestataireHistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() =>
      ref.read(prestataireAgendaProvider.notifier).reload();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agendaAsync = ref.watch(prestataireAgendaProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: agendaAsync.when(
        loading: () => const PrestataireWorkspaceShell(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => PrestataireWorkspaceShell(
          onRefresh: _reload,
          child: Center(
            child: DiscoveryEmptyState(
              icon: Icons.cloud_off_outlined,
              title: DiscPrestaAgenda.loadErr,
              body: DiscList.pullDownHint,
              iconColor: theme.colorScheme.error,
              actionLabel: DiscList.retry,
              onAction: _reload,
            ),
          ),
        ),
        data: (reservations) {
          final all = listPrestataireClientSummaries(reservations);
          final q = _query.trim().toLowerCase();
          final clients = q.isEmpty
              ? all
              : all
                  .where(
                    (c) =>
                        c.clientName.toLowerCase().contains(q) ||
                        c.lastServiceName.toLowerCase().contains(q),
                  )
                  .toList();

          return PrestataireWorkspaceShell(
            onRefresh: _reload,
            headerSubtitle: DiscPrestaWorkspace.clientsSubtitle,
            child: RefreshIndicator(
              onRefresh: _reload,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: PrestataireProfileCompletionCard(),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Text(
                        DiscPrestaClients.pageTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.12),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: DiscPrestaWorkspace.clientsSearchHint,
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _query = value),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Text(
                        DiscPrestaWorkspace.clientsCount(clients.length),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  if (clients.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: DiscoveryEmptyState(
                        icon: Icons.groups_rounded,
                        title: DiscPrestaClients.emptyTitle,
                        body: DiscPrestaClients.emptyBody,
                        iconColor:
                            theme.colorScheme.primary.withValues(alpha: 0.75),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final summary = clients[index];
                          return Column(
                            children: [
                              if (index > 0)
                                Divider(
                                  height: 1,
                                  indent: 76,
                                  color: theme.colorScheme.outline
                                      .withValues(alpha: 0.1),
                                ),
                              PrestataireClientRowCard(
                                summary: summary,
                                onTap: () {
                                  final latest = summary.reservations.first;
                                  context.pushPrestataireReservationDetail(
                                    latest.id,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                        childCount: clients.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}

