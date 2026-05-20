import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final status = clientReservationUiStatusFromStatut(item.statut);
    final chip = chipColorsForReservationStatus(theme.colorScheme, status);
    final timeLabel = formatBookingTime(item.dateHeure);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.92 : 0.98,
        ),
        elevation: isDark ? 0 : 1,
        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: DiscoveryStyles.cardBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        timeLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: chip.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        clientReservationStatusLabel(status),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontFamily: AppFonts.body,
                          color: chip.foregroundColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.clientName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.serviceName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (item.notesClient?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Note client : ${item.notesClient!.trim()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.35,
                    ),
                  ),
                ],
                if (item.notesPrestataire?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Motif : ${item.notesPrestataire!.trim()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      height: 1.35,
                    ),
                  ),
                ],
                if (status == ClientReservationUiStatus.pending) ...[
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
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(DiscPrestaDash.accept),
                        ),
                      ),
                    ],
                  ),
                ],
                if (status == ClientReservationUiStatus.confirmed) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: busy ? null : onMarkDone,
                      child: Text(
                        busy ? '…' : DiscPrestaAgenda.markDone,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
