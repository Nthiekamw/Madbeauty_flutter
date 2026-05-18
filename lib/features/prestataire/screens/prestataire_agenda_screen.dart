import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/widgets/role_switch_section.dart';
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
    final list =
        all.where((r) => isSameDay(r.dateHeure, day)).toList()
          ..sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return list;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscNav.prestAgenda),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                DiscPrestaAgenda.realtimeHint,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: agendaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              DiscPrestaAgenda.loadErr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
        data: (reservations) {
          final dayReservations = _dayItems(reservations, _selectedDay);

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(prestataireAgendaProvider.notifier).reload(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const RoleSwitchSection(sectionTitle: DiscNav.profileSpace),
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
                Text(
                  formatBookingDate(_selectedDay),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                if (dayReservations.isEmpty)
                  const PrestataireDashboardEmptyHint(
                    message: DiscPrestaAgenda.dayEmpty,
                  )
                else
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
          );
        },
      ),
    );
  }
}
