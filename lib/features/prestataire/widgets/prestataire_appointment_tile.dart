import 'package:flutter/material.dart';

import '../../booking/logic/booking_formatters.dart';
import '../models/prestataire_reservation_item.dart';

class PrestataireAppointmentTile extends StatelessWidget {
  const PrestataireAppointmentTile({
    super.key,
    required this.item,
    this.showDate = false,
  });

  final PrestataireReservationItem item;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = formatBookingTime(item.dateHeure);
    final dateLabel = showDate ? formatBookingDate(item.dateHeure) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Text(
            timeLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(
          item.clientName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          [
            item.serviceName,
            if (dateLabel != null) dateLabel,
          ].join(' · '),
        ),
        isThreeLine: dateLabel != null,
      ),
    );
  }
}
