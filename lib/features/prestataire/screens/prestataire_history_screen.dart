import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/widgets/discovery/content/discovery_section_header.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../logic/prestataire_clients_grouping.dart';
import '../providers/agenda/prestataire_agenda_provider.dart';
import '../widgets/workspace/prestataire_client_row_card.dart';
import '../widgets/workspace/prestataire_profile_completion_card.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';
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

    return PrestataireBrandScaffold(
      body: agendaAsync.when(
        loading: () => const PrestataireWorkspaceShell(
          title: ShellStrings.navPrestataireClients,
          subtitle: DiscPrestaWorkspace.clientsSubtitle,
          child: DiscoveryListSkeleton(rowCount: 5, rowHeight: 88),
        ),
        error: (_, __) => PrestataireWorkspaceShell(
          title: ShellStrings.navPrestataireClients,
          subtitle: DiscPrestaWorkspace.clientsSubtitle,
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
          final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
          final hPad = useWeb ? 16.0 : 20.0;
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
            title: ShellStrings.navPrestataireClients,
            subtitle: DiscPrestaWorkspace.clientsSubtitle,
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
                      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
                      child: useWeb
                          ? const SizedBox.shrink()
                          : DiscoverySectionHeader(
                              title: DiscPrestaClients.pageTitle,
                              subtitle: DiscPrestaWorkspace.clientsSubtitle,
                              icon: Icons.groups_rounded,
                              compact: true,
                              showSubtitleWhenCompact: true,
                            ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceFor(theme.brightness),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(
                              alpha: theme.brightness == Brightness.dark
                                  ? 0.28
                                  : 0.1,
                            ),
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
                      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 8),
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
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 32),
                      sliver: SliverList.separated(
                        itemCount: clients.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final summary = clients[index];
                          return PrestataireClientRowCard(
                            summary: summary,
                            onTap: () {
                              final latest = summary.reservations.first;
                              context.pushPrestataireReservationDetail(
                                latest.id,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
          );
        },
        ),
    );
  }
}

