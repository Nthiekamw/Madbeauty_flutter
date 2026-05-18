import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../booking/logic/booking_formatters.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import '../models/prestataire_reservation_item.dart';

class PrestataireAgendaReservationCard extends StatelessWidget {
  const PrestataireAgendaReservationCard({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onReject,
    required this.onMarkDone,
    this.busy = false,
  });

  final PrestataireReservationItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkDone;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = clientReservationUiStatusFromStatut(item.statut);
    final chip = chipColorsForReservationStatus(theme.colorScheme, status);
    final timeLabel = formatBookingTime(item.dateHeure);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  timeLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text(clientReservationStatusLabel(status)),
                  backgroundColor: chip.backgroundColor,
                  labelStyle: TextStyle(
                    color: chip.foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.clientName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              item.serviceName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (item.notesClient?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(
                'Note client : ${item.notesClient!.trim()}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (item.notesPrestataire?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                'Motif : ${item.notesPrestataire!.trim()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (status == ClientReservationUiStatus.pending) ...[
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
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(DiscPrestaDash.accept),
                    ),
                  ),
                ],
              ),
            ],
            if (status == ClientReservationUiStatus.confirmed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: busy ? null : onMarkDone,
                  child: Text(
                    busy
                        ? '…'
                        : DiscPrestaAgenda.markDone,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
