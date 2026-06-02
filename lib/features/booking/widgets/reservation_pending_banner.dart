import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../logic/client_reservation_ui_status.dart';

/// Bandeau « en attente de confirmation » sur une réservation cliente.
class ReservationPendingBanner extends StatelessWidget {
  const ReservationPendingBanner({
    super.key,
    required this.statut,
  });

  final String statut;

  @override
  Widget build(BuildContext context) {
    final ui = clientReservationUiStatusFromStatut(statut);
    if (ui != ClientReservationUiStatus.pending &&
        ui != ClientReservationUiStatus.syncPending) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final tertiary = theme.colorScheme.tertiary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tertiary.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded, size: 20, color: tertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              DiscBk.pendingPrestaBanner,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
