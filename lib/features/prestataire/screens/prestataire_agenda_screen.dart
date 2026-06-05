import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../booking/logic/booking_formatters.dart';
import '../logic/prestataire_agenda_filters.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/prestataire_agenda_provider.dart';
import '../widgets/agenda/prestataire_agenda_week_calendar.dart';
import '../widgets/workspace/prestataire_compact_appointment_card.dart';
import '../widgets/workspace/prestataire_profile_completion_card.dart';
import '../widgets/workspace/prestataire_segmented_tabs.dart';
import '../widgets/workspace/prestataire_workspace_shell.dart';

class PrestataireAgendaScreen extends ConsumerStatefulWidget {
  const PrestataireAgendaScreen({super.key});

  @override
  ConsumerState<PrestataireAgendaScreen> createState() =>
      _PrestataireAgendaScreenState();
}

class _PrestataireAgendaScreenState extends ConsumerState<PrestataireAgendaScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  PrestataireAgendaTab _tab = PrestataireAgendaTab.upcoming;
  String? _actingReservationId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
  }

  void _goToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _selectedDay = today;
      _focusedDay = today;
    });
  }

  PrestataireReservationActions get _actions =>
      PrestataireReservationActions(ref, context);

  Future<void> _runAction(
    String id,
    Future<bool> Function() action,
  ) async {
    setState(() => _actingReservationId = id);
    await action();
    if (mounted) setState(() => _actingReservationId = null);
  }

  Future<void> _reload() =>
      ref.read(prestataireAgendaProvider.notifier).reload();

  List<Widget> _buildAgendaList(
    BuildContext context,
    List<DateTime> sortedDays,
    Map<DateTime, List<PrestataireReservationItem>> grouped,
  ) {
    final theme = Theme.of(context);
    final widgets = <Widget>[];

    for (final day in sortedDays) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text(
            formatBookingDate(day),
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
      for (final item in grouped[day]!) {
        final busy = _actingReservationId == item.id;
        widgets.add(
          PrestataireCompactAppointmentCard(
            item: item,
            busy: busy,
            onTap: () => context.pushPrestataireReservationDetail(item.id),
            onAccept: () => _runAction(
              item.id,
              () => _actions.accept(item.id),
            ),
            onReject: () =>
                _runAction(item.id, () => _actions.reject(item.id)),
            onMarkDone: () =>
                _runAction(item.id, () => _actions.markDone(item.id)),
          ),
        );
      }
    }
    return widgets;
  }

  String _tabLabel(PrestataireAgendaTab tab) => switch (tab) {
        PrestataireAgendaTab.upcoming => DiscPrestaWorkspace.agendaTabUpcoming,
        PrestataireAgendaTab.past => DiscPrestaWorkspace.agendaTabPast,
        PrestataireAgendaTab.cancelled =>
          DiscPrestaWorkspace.agendaTabCancelled,
      };

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
          final filtered =
              filterPrestataireAgendaReservations(reservations, _tab);
          final grouped = groupReservationsByDay(filtered);
          final sortedDays = grouped.keys.toList()
            ..sort(
              (a, b) => _tab == PrestataireAgendaTab.past
                  ? b.compareTo(a)
                  : a.compareTo(b),
            );

          return PrestataireWorkspaceShell(
            onRefresh: _reload,
            headerSubtitle: DiscPrestaWorkspace.agendaSubtitle,
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DiscNav.prestAgenda,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PrestataireSegmentedTabs<PrestataireAgendaTab>(
                        tabs: PrestataireAgendaTab.values,
                        selected: _tab,
                        onSelected: (t) => setState(() => _tab = t),
                        labelBuilder: _tabLabel,
                      ),
                    ),
                  ),
                  if (_tab == PrestataireAgendaTab.upcoming) ...[
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PrestataireAgendaWeekCalendar(
                          focusedDay: _focusedDay,
                          selectedDay: _selectedDay,
                          reservations: reservations,
                          onTodayPressed: _goToToday,
                          onDaySelected: (selected, focused) {
                            setState(() {
                              _selectedDay = DateTime(
                                selected.year,
                                selected.month,
                                selected.day,
                              );
                              _focusedDay = focused;
                            });
                          },
                          onPageChanged: (focused) {
                            setState(() => _focusedDay = focused);
                          },
                        ),
                      ),
                    ),
                  ],
                  if (filtered.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: DiscoveryEmptyState(
                        icon: Icons.event_available_outlined,
                        title: DiscPrestaAgenda.dayEmptyTitle,
                        body: DiscPrestaAgenda.dayEmptyBody,
                        iconColor: theme.colorScheme.primary
                            .withValues(alpha: 0.7),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          _buildAgendaList(
                            context,
                            sortedDays,
                            grouped,
                          ),
                        ),
                      ),
                    ),
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

