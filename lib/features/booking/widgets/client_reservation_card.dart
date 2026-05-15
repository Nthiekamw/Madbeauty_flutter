import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../logic/booking_formatters.dart';
import '../logic/client_reservation_ui_status.dart';
import '../models/client_reservation_summary.dart';

class ClientReservationCard extends StatelessWidget {
  const ClientReservationCard({
    super.key,
    required this.item,
    this.onCancel,
    this.cancelLoading = false,
  });

  final ClientReservationSummary item;
  final VoidCallback? onCancel;
  final bool cancelLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final prestataireLabel =
        item.prestataireName?.trim().isNotEmpty == true
            ? item.prestataireName!.trim()
            : DiscBk.unknownPresta;
    final serviceLabel =
        item.serviceName?.trim().isNotEmpty == true
            ? item.serviceName!.trim()
            : DiscBk.unknownSvc;

    final uiStatus = clientReservationUiStatusFromStatut(item.statut);
    final chipStyle = chipColorsForReservationStatus(cs, uiStatus);
    final showCancel =
        onCancel != null && clientReservationCanCancel(uiStatus);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(
                  imageUrl: item.prestataireAvatarUrl,
                  displayName: prestataireLabel,
                  radius: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prestataireLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        serviceLabel,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatBookingDate(item.dateHeure),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_outlined,
                                size: 16,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatBookingTime(item.dateHeure),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipStyle.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    clientReservationStatusLabel(uiStatus),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: chipStyle.foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (showCancel)
                  AppButton(
                    variant: AppButtonVariant.secondary,
                    isLoading: cancelLoading,
                    enabled: !cancelLoading,
                    onPressed: onCancel,
                    child: Text(DiscBk.revokeLabel),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
