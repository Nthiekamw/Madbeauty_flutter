import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../booking/logic/booking_formatters.dart';
import '../../../../booking/logic/client_reservation_ui_status.dart';
import '../../../logic/prestataire_reservation_completion.dart';
import '../../../models/prestataire_reservation_item.dart';
import '../../shared/prestataire_client_identity_row.dart';

/// Carte rendez-vous compacte (heure Â· client Â· statut).
class PrestataireCompactAppointmentCard extends StatelessWidget {
  const PrestataireCompactAppointmentCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onAccept,
    this.onReject,
    this.onMarkDone,
    this.busy = false,
  });

  final PrestataireReservationItem item;
  final VoidCallback onTap;
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
    final showActions = status == ClientReservationUiStatus.pending &&
        (onAccept != null || onReject != null);
    final canMarkDone = status == ClientReservationUiStatus.confirmed &&
        onMarkDone != null &&
        prestataireCanMarkReservationDone(item);
    final showMarkDoneHint = status == ClientReservationUiStatus.confirmed &&
        onMarkDone != null &&
        !prestataireCanMarkReservationDone(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cardSurfaceFor(theme.brightness),
        elevation: 0,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.28 : 0.1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        timeLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: PrestataireClientIdentityRow(
                        clientName: item.clientDisplayName,
                        clientPrenom: item.clientPrenom,
                        clientNom: item.clientNom,
                        serviceName: item.serviceName,
                        clientAvatarUrl: item.clientAvatarUrl,
                        avatarRadius: 22,
                        nameStyle: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: chip.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        clientReservationStatusLabel(status),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: chip.foregroundColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if (showActions) ...[
                  const SizedBox(height: 10),
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
                ] else if (canMarkDone) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: busy ? null : onMarkDone,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(DiscPrestaAgenda.markDone),
                    ),
                  ),
                ] else if (showMarkDoneHint) ...[
                  const SizedBox(height: 8),
                  Text(
                    DiscPrestaAgenda.markDonePendingHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
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

