import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../logic/booking_formatters.dart';
import '../models/booking_slot.dart';

class SlotChoiceWrap extends StatelessWidget {
  const SlotChoiceWrap({
    super.key,
    required this.slots,
    required this.bookedSlots,
    required this.selectedSlot,
    required this.onSelected,
  });

  final List<BookingSlot> slots;
  final Set<BookingSlot> bookedSlots;
  final BookingSlot? selectedSlot;
  final ValueChanged<BookingSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final slot in slots)
          _SlotChip(
            slot: slot,
            selected: selectedSlot == slot,
            booked: bookedSlots.contains(slot),
            onSelected: onSelected,
          ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.booked,
    required this.onSelected,
  });

  final BookingSlot slot;
  final bool selected;
  final bool booked;
  final ValueChanged<BookingSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    final label = Text(formatBookingSlot(slot));
    final chip = ChoiceChip(
      label: label,
      selected: selected,
      onSelected: booked ? null : (_) => onSelected(slot),
    );

    if (!booked) return chip;

    return Tooltip(
      message: DiscBk.bookedSlotTooltip,
      child: chip,
    );
  }
}
