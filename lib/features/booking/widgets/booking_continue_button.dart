import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
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
    final theme = Theme.of(context);
    final slot = selectedSlot;
    final primary = theme.colorScheme.primary;
    final isEnabled = enabled && slot != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: isEnabled ? onPressed : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: isEnabled ? primary : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                slot == null ? Icons.touch_app_rounded : Icons.check_circle_rounded,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                slot == null
                    ? DiscBk.pickSlot
                    : DiscBk.continueWithSlot(formatBookingSlot(slot)),
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

