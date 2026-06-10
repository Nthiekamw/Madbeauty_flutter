import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Affiche le motif de refus prestataire (réservation annulée).
class ReservationRejectReasonBox extends StatelessWidget {
  const ReservationRejectReasonBox({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: error.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DiscBk.rejectReasonTitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: error,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reason.trim(),
              style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

