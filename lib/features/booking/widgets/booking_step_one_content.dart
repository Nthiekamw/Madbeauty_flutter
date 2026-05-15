import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../logic/booking_formatters.dart';
import '../models/booking_availability_rules.dart';
import '../models/booking_selection_state.dart';
import '../models/booking_slot.dart';
import 'availability_calendar.dart';
import 'booking_continue_button.dart';
import 'booking_section_title.dart';
import 'selected_service_header.dart';
import 'service_choice_card.dart';
import 'slot_choice_wrap.dart';

class BookingStepOneContent extends StatelessWidget {
  const BookingStepOneContent({
    super.key,
    required this.services,
    required this.selectedService,
    required this.selection,
    required this.availabilityRules,
    required this.bookedSlots,
    required this.bookedSlotsLoading,
    required this.canConfirm,
    required this.onServiceSelected,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onSlotSelected,
    required this.onContinue,
  });

  final List<ServiceBeaute> services;
  final ServiceBeaute selectedService;
  final BookingSelectionState selection;
  final BookingAvailabilityRules availabilityRules;
  final Set<BookingSlot> bookedSlots;
  final bool bookedSlotsLoading;
  final bool canConfirm;
  final ValueChanged<String> onServiceSelected;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final ValueChanged<BookingSlot> onSlotSelected;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final slots = availabilityRules.slotsForDay(selection.selectedDay);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        SelectedServiceHeader(service: selectedService),
        const SizedBox(height: 18),
        BookingSectionTitle(
          title: DiscBk.stepService,
          subtitle: DiscBk.svcCountLabel(services.length),
        ),
        const SizedBox(height: 10),
        for (final service in services) ...[
          ServiceChoiceCard(
            service: service,
            selected: service.id == selectedService.id,
            onTap: () => onServiceSelected(service.id),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        const BookingSectionTitle(
          title: DiscBk.stepDate,
          subtitle: DiscBk.stepDateSub,
        ),
        const SizedBox(height: 10),
        AvailabilityCalendar(
          rules: availabilityRules,
          focusedDay: selection.focusedDay,
          selectedDay: selection.selectedDay,
          onDaySelected: (selectedDay, focusedDay) {
            if (!availabilityRules.isAvailableDay(selectedDay)) return;
            onDaySelected(selectedDay, focusedDay);
          },
          onPageChanged: onPageChanged,
        ),
        const SizedBox(height: 18),
        BookingSectionTitle(
          title: DiscBk.stepSlots,
          subtitle: formatBookingDate(selection.selectedDay),
        ),
        const SizedBox(height: 10),
        if (slots.isEmpty)
          Text(
            DiscBk.noSlotsDay,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          SlotChoiceWrap(
            slots: slots,
            bookedSlots: bookedSlots,
            selectedSlot: selection.selectedSlot,
            onSelected: onSlotSelected,
          ),
        if (bookedSlotsLoading) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
        const SizedBox(height: 24),
        BookingContinueButton(
          enabled: canConfirm,
          selectedSlot: selection.selectedSlot,
          onPressed: onContinue,
        ),
      ],
    );
  }
}
