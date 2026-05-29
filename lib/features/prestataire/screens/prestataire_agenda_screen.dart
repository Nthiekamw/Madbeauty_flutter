import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../booking/logic/booking_formatters.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/prestataire_agenda_provider.dart';
import '../widgets/agenda/prestataire_agenda_day_section.dart';
import '../widgets/agenda/prestataire_agenda_stats_strip.dart';
import '../widgets/agenda/prestataire_agenda_week_calendar.dart';

class PrestataireAgendaScreen extends ConsumerStatefulWidget {
  const PrestataireAgendaScreen({super.key});

  @override
  ConsumerState<PrestataireAgendaScreen> createState() =>
      _PrestataireAgendaScreenState();
}

class _PrestataireAgendaScreenState extends ConsumerState<PrestataireAgendaScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
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

  List<PrestataireReservationItem> _dayItems(
    List<PrestataireReservationItem> all,
    DateTime day,
  ) {
    return all.where((r) => isSameDay(r.dateHeure, day)).toList()
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
  }

  int _pendingCount(List<PrestataireReservationItem> all) {
    return all
        .where(
          (r) =>
              clientReservationUiStatusFromStatut(r.statut) ==
              ClientReservationUiStatus.pending,
        )
        .length;
  }

  int _weekCount(List<PrestataireReservationItem> all, DateTime anchor) {
    final start = anchor.subtract(Duration(days: anchor.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return all
        .where((r) {
          final d = DateTime(
            r.dateHeure.year,
            r.dateHeure.month,
            r.dateHeure.day,
          );
          return !d.isBefore(start) &&
              !d.isAfter(end) &&
              clientReservationUiStatusFromStatut(r.statut) !=
                  ClientReservationUiStatus.cancelled;
        })
        .length;
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

  @override
  Widget build(BuildContext context) {
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
          final dayReservations = _dayItems(reservations, _selectedDay);
          final pendingCount = _pendingCount(reservations);
          final weekCount = _weekCount(reservations, _focusedDay);

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(prestataireAgendaProvider.notifier).reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                const DiscoveryScreenHeader(
                  title: DiscNav.prestAgenda,
                  subtitle: DiscPrestaAgenda.pageSubtitle,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.18,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sync_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DiscPrestaAgenda.realtimeHint,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontFamily: AppFonts.body,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                PrestataireAgendaStatsStrip(
                  selectedDayCount: dayReservations.length,
                  pendingCount: pendingCount,
                  weekCount: weekCount,
                ),
                const SizedBox(height: 16),
                PrestataireAgendaWeekCalendar(
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
                const SizedBox(height: 16),
                PrestataireAgendaDaySection(
                  dateLabel: formatBookingDate(_selectedDay),
                  items: dayReservations,
                  busyReservationId: _actingReservationId,
                  onAccept: (id) => _runAction(id, () => _actions.accept(id)),
                  onReject: (id) => _runAction(id, () => _actions.reject(id)),
                  onMarkDone: (id) =>
                      _runAction(id, () => _actions.markDone(id)),
                  onItemTap: (id) =>
                      context.pushPrestataireReservationDetail(id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
