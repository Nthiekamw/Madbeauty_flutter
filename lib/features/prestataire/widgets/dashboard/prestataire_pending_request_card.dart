import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../booking/logic/booking_formatters.dart';
import '../../../booking/widgets/reservation_payment_summary_card.dart';
import '../../models/prestataire_reservation_item.dart';

class PrestatairePendingRequestCard extends StatelessWidget {
  const PrestatairePendingRequestCard({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onReject,
    this.busy = false,
  });

  final PrestataireReservationItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateLabel = formatBookingDate(item.dateHeure);
    final timeLabel = formatBookingTime(item.dateHeure);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.85 : 0.95,
        ),
        borderRadius: DiscoveryStyles.chipBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.chipBorderRadius,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.clientName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.serviceName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$dateLabel · $timeLabel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (item.paymentDisplay.shouldShow) ...[
                  const SizedBox(height: 10),
                  ReservationPaymentSummaryCard(
                    display: item.paymentDisplay,
                    lines: item.paymentDisplay.prestataireLines(),
                    compact: true,
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: busy ? null : onReject,
                        child: const Text(DiscPrestaDash.reject),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: busy ? null : onAccept,
                        child: busy
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : const Text(DiscPrestaDash.accept),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
