import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery_empty_state.dart';
import '../../../shared/widgets/discovery_screen_header.dart';
import '../../booking/logic/booking_formatters.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/prestataire_agenda_provider.dart';
import '../widgets/prestataire_agenda_reservation_card.dart';
import '../widgets/prestataire_agenda_week_calendar.dart';
import '../widgets/prestataire_dashboard_section.dart';

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

  List<PrestataireReservationItem> _dayItems(
    List<PrestataireReservationItem> all,
    DateTime day,
  ) {
    return all.where((r) => isSameDay(r.dateHeure, day)).toList()
      ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sync_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DiscPrestaAgenda.realtimeHint,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PrestataireAgendaWeekCalendar(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  reservations: reservations,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatBookingDate(_selectedDay),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (dayReservations.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${dayReservations.length}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontFamily: AppFonts.body,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (dayReservations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: PrestataireDashboardEmptyHint(
                      message: DiscPrestaAgenda.dayEmpty,
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        for (final item in dayReservations)
                          PrestataireAgendaReservationCard(
                            item: item,
                            busy: _actingReservationId == item.id,
                            onAccept: _actingReservationId != null
                                ? null
                                : () => _runAction(
                                    item.id,
                                    () => _actions.accept(item.id),
                                  ),
                            onReject: _actingReservationId != null
                                ? null
                                : () => _runAction(
                                    item.id,
                                    () => _actions.reject(item.id),
                                  ),
                            onMarkDone: _actingReservationId != null
                                ? null
                                : () => _runAction(
                                    item.id,
                                    () => _actions.markDone(item.id),
                                  ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
