import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking_availability_rules.dart';
import '../models/booking_selection_state.dart';
import '../models/booking_slot.dart';
import 'booking_availability_provider.dart';

final bookingSelectionProvider =
    NotifierProvider<BookingSelectionNotifier, BookingSelectionState>(
      BookingSelectionNotifier.new,
    );

class BookingSelectionNotifier extends Notifier<BookingSelectionState> {
  @override
  BookingSelectionState build() {
    return _initialState();
  }

  void initialize({String? serviceId}) {
    final id = serviceId?.trim();
    state = _initialState(
      selectedServiceId: id == null || id.isEmpty ? null : id,
    );
  }

  void selectService(String serviceId) {
    state = state.copyWith(selectedServiceId: serviceId, selectedSlot: null);
  }

  void selectDay(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(
      selectedDay: bookingDateOnly(selectedDay),
      focusedDay: bookingDateOnly(focusedDay),
      selectedSlot: null,
    );
  }

  void setFocusedDay(DateTime focusedDay) {
    state = state.copyWith(focusedDay: bookingDateOnly(focusedDay));
  }

  void selectSlot(BookingSlot slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  void clearSlotIfBooked(Set<BookingSlot> bookedSlots) {
    final slot = state.selectedSlot;
    if (slot != null && bookedSlots.contains(slot)) {
      state = state.copyWith(selectedSlot: null);
    }
  }

  BookingSelectionState _initialState({String? selectedServiceId}) {
    final rules = ref.read(bookingAvailabilityRulesProvider);
    final today = bookingDateOnly(DateTime.now());
    return BookingSelectionState(
      focusedDay: today,
      selectedDay: rules.nextAvailableDay(today, now: today),
      selectedServiceId: selectedServiceId,
    );
  }
}

