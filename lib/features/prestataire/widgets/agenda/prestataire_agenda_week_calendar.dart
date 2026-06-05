import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../booking/logic/client_reservation_ui_status.dart';
import '../../models/prestataire_reservation_item.dart';

class PrestataireAgendaWeekCalendar extends StatelessWidget {
  const PrestataireAgendaWeekCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.reservations,
    required this.onDaySelected,
    required this.onPageChanged,
    this.onTodayPressed,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<PrestataireReservationItem> reservations;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final VoidCallback? onTodayPressed;

  List<PrestataireReservationItem> _forDay(DateTime day) {
    return reservations.where((r) => isSameDay(r.dateHeure, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final showTodayAction = onTodayPressed != null && !isSameDay(selectedDay, today);
    final firstDay = today.subtract(const Duration(days: 365));
    final lastDay = today.add(const Duration(days: 365));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTodayAction)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTodayPressed,
                icon: const Icon(Icons.today_rounded, size: 18),
                label: const Text(DiscPrestaAgenda.todayAction),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        DiscoverySurfaceCard(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
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
                final count = _forDay(day).length;
                return List.filled(count, '');
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                headerPadding: const EdgeInsets.only(bottom: 8),
                titleTextStyle: theme.textTheme.titleSmall!.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
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
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                weekendStyle: theme.textTheme.labelMedium!.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.all(6),
                outsideDaysVisible: false,
                defaultTextStyle: theme.textTheme.bodyMedium!.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                ),
                weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                ),
                selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
                  fontFamily: AppFonts.body,
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
                todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;
                  final dayItems = _forDay(day);
                  final dots = <Color>[];
                  for (final item in dayItems) {
                    final status =
                        clientReservationUiStatusFromStatut(item.statut);
                    final color = switch (status) {
                      ClientReservationUiStatus.pending =>
                        theme.colorScheme.tertiary,
                      ClientReservationUiStatus.confirmed =>
                        theme.colorScheme.primary,
                      ClientReservationUiStatus.done =>
                        theme.colorScheme.secondary,
                      ClientReservationUiStatus.cancelled =>
                        theme.colorScheme.error,
                      _ => theme.colorScheme.outline,
                    };
                    if (!dots.contains(color)) dots.add(color);
                    if (dots.length >= 3) break;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final color in dots)
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

