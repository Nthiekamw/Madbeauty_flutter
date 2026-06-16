import '../../../shared/utils/currency_format.dart';
import '../models/booking_slot.dart';

String formatBookingServiceMeta({
  required int durationMinutes,
  required double price,
}) {
  return '$durationMinutes min · ${CurrencyFormat.eur(price, decimals: true)}';
}

String formatBookingDate(DateTime day) {
  const weekdays = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];
  const months = [
    'janvier',
    'février',
    'mars',
    'avril',
    'mai',
    'juin',
    'juillet',
    'août',
    'septembre',
    'octobre',
    'novembre',
    'décembre',
  ];
  return '${weekdays[day.weekday - 1]} ${day.day} ${months[day.month - 1]}';
}

/// Abréviation mois (badge calendrier compact).
String formatBookingMonthShort(DateTime day) {
  const months = [
    'JAN',
    'FÉV',
    'MAR',
    'AVR',
    'MAI',
    'JUN',
    'JUL',
    'AOÛ',
    'SEP',
    'OCT',
    'NOV',
    'DÉC',
  ];
  return months[day.toLocal().month - 1];
}

/// Jour de la semaine seul (ex. « mercredi »).
String formatBookingWeekday(DateTime day) {
  const weekdays = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];
  return weekdays[day.toLocal().weekday - 1];
}

String formatBookingSlot(BookingSlot slot) => slot.label;

String formatBookingTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

