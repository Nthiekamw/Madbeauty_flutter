import 'booking_availability_rules.dart';

class BookedSlotsQuery {
  const BookedSlotsQuery({
    required this.prestataireId,
    required this.serviceId,
    required this.day,
  });

  final String prestataireId;
  final String serviceId;
  final DateTime day;

  DateTime get normalizedDay => bookingDateOnly(day);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookedSlotsQuery &&
            runtimeType == other.runtimeType &&
            prestataireId == other.prestataireId &&
            serviceId == other.serviceId &&
            normalizedDay == other.normalizedDay;
  }

  @override
  int get hashCode => Object.hash(prestataireId, serviceId, normalizedDay);
}

