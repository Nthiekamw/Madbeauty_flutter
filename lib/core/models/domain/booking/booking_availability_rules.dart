import 'package:madbeauty/core/models/domain/booking/booking_slot.dart';

class BookingAvailabilityRules {
  const BookingAvailabilityRules({
    required this.slotsByWeekday,
    this.daysAhead = 60,
  });

  /// Map clé = [DateTime.monday]..[DateTime.sunday].
  /// Une journée avec une liste vide est considérée indisponible.
  final Map<int, List<BookingSlot>> slotsByWeekday;
  final int daysAhead;

  DateTime firstDay(DateTime now) => bookingDateOnly(now);

  DateTime lastDay(DateTime now) {
    return firstDay(now).add(Duration(days: daysAhead));
  }

  bool isAvailableDay(DateTime day, {DateTime? now}) {
    final current = bookingDateOnly(day);
    final start = firstDay(now ?? DateTime.now());
    final end = lastDay(now ?? DateTime.now());
    if (current.isBefore(start) || current.isAfter(end)) return false;
    return _slotsForWeekday(current.weekday).isNotEmpty;
  }

  DateTime nextAvailableDay(DateTime from, {DateTime? now}) {
    var candidate = bookingDateOnly(from);
    final end = lastDay(now ?? DateTime.now());
    while (!candidate.isAfter(end)) {
      if (isAvailableDay(candidate, now: now)) return candidate;
      candidate = candidate.add(const Duration(days: 1));
    }
    return bookingDateOnly(from);
  }

  List<BookingSlot> slotsForDay(DateTime day, {DateTime? now}) {
    if (!isAvailableDay(day, now: now)) return const [];
    return _slotsForWeekday(day.weekday);
  }

  List<BookingSlot> _slotsForWeekday(int weekday) {
    return slotsByWeekday[weekday] ?? const [];
  }
}

DateTime bookingDateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
