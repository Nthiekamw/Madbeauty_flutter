import 'booking_slot.dart';

class BookingSelectionState {
  const BookingSelectionState({
    required this.focusedDay,
    required this.selectedDay,
    this.selectedServiceId,
    this.selectedSlot,
  });

  final DateTime focusedDay;
  final DateTime selectedDay;
  final String? selectedServiceId;
  final BookingSlot? selectedSlot;

  BookingSelectionState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Object? selectedServiceId = _unset,
    Object? selectedSlot = _unset,
  }) {
    return BookingSelectionState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedServiceId: identical(selectedServiceId, _unset)
          ? this.selectedServiceId
          : selectedServiceId as String?,
      selectedSlot: identical(selectedSlot, _unset)
          ? this.selectedSlot
          : selectedSlot as BookingSlot?,
    );
  }
}

const _unset = Object();
