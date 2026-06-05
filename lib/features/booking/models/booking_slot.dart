class BookingSlot {
  const BookingSlot({required this.hour, required this.minute});

  factory BookingSlot.fromDateTime(DateTime value) {
    return BookingSlot(hour: value.hour, minute: value.minute);
  }

  final int hour;
  final int minute;

  String get label {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  DateTime onDay(DateTime day) {
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingSlot &&
            runtimeType == other.runtimeType &&
            hour == other.hour &&
            minute == other.minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}

