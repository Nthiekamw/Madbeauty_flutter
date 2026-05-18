import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../booking/logic/booking_formatters.dart';
import '../models/prestataire_reservation_item.dart';

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
    final dateLabel = formatBookingDate(item.dateHeure);
    final timeLabel = formatBookingTime(item.dateHeure);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.clientName,
              style: theme.textTheme.titleMedium?.copyWith(
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
            const SizedBox(height: 6),
            Text(
              '$dateLabel · $timeLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
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
    );
  }
}
