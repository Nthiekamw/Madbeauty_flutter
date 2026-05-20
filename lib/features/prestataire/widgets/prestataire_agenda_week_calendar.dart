import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
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

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
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
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleSmall!.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: theme.colorScheme.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: theme.textTheme.labelMedium!.copyWith(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          weekendStyle: theme.textTheme.labelMedium!.copyWith(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        calendarStyle: CalendarStyle(
          markerSize: 6,
          markersMaxCount: 3,
          markerDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
            fontFamily: AppFonts.body,
          ),
          weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
            fontFamily: AppFonts.body,
          ),
          selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
            fontFamily: AppFonts.body,
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
          todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
          outsideDaysVisible: false,
        ),
      ),
    );
  }
}
