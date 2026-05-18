import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_strings.dart';
import '../models/prestataire_reservation_item.dart';

class PrestataireAgendaWeekCalendar extends StatelessWidget {
  const PrestataireAgendaWeekCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.reservations,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<PrestataireReservationItem> reservations;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDay = DateTime.now().subtract(const Duration(days: 365));
    final lastDay = DateTime.now().add(const Duration(days: 365));

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar<String>(
          locale: 'fr_FR',
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: const {
            CalendarFormat.week: DiscPrestaAgenda.weekFormat,
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          eventLoader: (day) {
            final count = reservations
                .where((r) => isSameDay(r.dateHeure, day))
                .length;
            return List.filled(count, '');
          },
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            markerSize: 6,
            markersMaxCount: 3,
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
