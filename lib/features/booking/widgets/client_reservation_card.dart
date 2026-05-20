import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
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
    final isDark = theme.brightness == Brightness.dark;

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

    return Material(
      color: theme.colorScheme.surface.withValues(
        alpha: isDark ? 0.92 : 0.98,
      ),
      elevation: isDark ? 0 : 1,
      shadowColor: cs.primary.withValues(alpha: 0.1),
      borderRadius: DiscoveryStyles.cardBorderRadius,
      child: InkWell(
        borderRadius: DiscoveryStyles.cardBorderRadius,
        onTap: null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.14),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAvatar(
                      imageUrl: item.prestataireAvatarUrl,
                      displayName: prestataireLabel,
                      radius: 30,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prestataireLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            serviceLabel,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontFamily: AppFonts.body,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _MetaRow(
                            icon: Icons.calendar_today_outlined,
                            text: formatBookingDate(item.dateHeure),
                          ),
                          const SizedBox(height: 4),
                          _MetaRow(
                            icon: Icons.schedule_rounded,
                            text: formatBookingTime(item.dateHeure),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: chipStyle.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        clientReservationStatusLabel(uiStatus),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontFamily: AppFonts.body,
                          color: chipStyle.foregroundColor,
                          fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: AppFonts.body,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
