import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../booking/logic/booking_formatters.dart';
import '../../../booking/logic/client_reservation_ui_status.dart';
import '../../logic/prestataire_history_grouping.dart';
import '../../models/prestataire_reservation_item.dart';

class PrestataireHistoryClientSection extends StatelessWidget {
  const PrestataireHistoryClientSection({
    super.key,
    required this.group,
    required this.onReservationTap,
    this.initiallyExpanded = false,
  });

  final PrestataireHistoryClientGroup group;
  final void Function(String reservationId) onReservationTap;
  final bool initiallyExpanded;

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DiscoverySurfaceCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              _initials(group.clientName),
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          title: Text(
            group.clientName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            DiscPrestaClients.clientReservationCount(group.reservations.length),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          children: [
            for (final item in group.reservations)
              _HistoryReservationTile(
                item: item,
                onTap: () => onReservationTap(item.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryReservationTile extends StatelessWidget {
  const _HistoryReservationTile({
    required this.item,
    required this.onTap,
  });

  final PrestataireReservationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = clientReservationUiStatusFromStatut(item.statut);
    final chip = chipColorsForReservationStatus(theme.colorScheme, status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
        ),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.serviceName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${formatBookingDate(item.dateHeure)} · ${formatBookingTime(item.dateHeure)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chip.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    clientReservationStatusLabel(status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: chip.foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
