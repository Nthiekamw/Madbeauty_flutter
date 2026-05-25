import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final label = formatBookingSlot(slot);

    Widget chip = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: booked
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : selected
                ? primary
                : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: booked
              ? theme.colorScheme.outline.withValues(alpha: 0.12)
              : selected
                  ? primary
                  : theme.colorScheme.outline.withValues(
                      alpha: isDark ? 0.2 : 0.15,
                    ),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected && !isDark
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (booked)
              Icon(
                Icons.block_rounded,
                size: 13,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              )
            else
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: booked
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                decoration: booked ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );

    if (booked) {
      return Tooltip(
        message: DiscBk.bookedSlotTooltip,
        child: chip,
      );
    }

    return GestureDetector(
      onTap: () => onSelected(slot),
      child: chip,
    );
  }
}
