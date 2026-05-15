import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../logic/booking_formatters.dart';
import '../models/booking_slot.dart';

class BookingContinueButton extends StatelessWidget {
  const BookingContinueButton({
    super.key,
    required this.enabled,
    required this.selectedSlot,
    required this.onPressed,
  });

  final bool enabled;
  final BookingSlot? selectedSlot;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final slot = selectedSlot;
    return FilledButton.icon(
      onPressed: enabled && slot != null ? onPressed : null,
      icon: const Icon(Icons.check),
      label: Text(
        slot == null
            ? DiscBk.pickSlot
            : DiscBk.continueWithSlot(formatBookingSlot(slot)),
      ),
    );
  }
}
