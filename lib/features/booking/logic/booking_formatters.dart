import '../models/booking_slot.dart';

String formatBookingServiceMeta({
  required int durationMinutes,
  required double price,
}) {
  return '$durationMinutes min â€¢ ${price.toStringAsFixed(2)} â‚¬';
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

String formatBookingSlot(BookingSlot slot) => slot.label;

String formatBookingTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

