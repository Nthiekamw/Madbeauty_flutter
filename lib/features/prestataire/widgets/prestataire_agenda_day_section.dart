import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_empty_state.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../models/prestataire_reservation_item.dart';
import 'prestataire_agenda_reservation_card.dart';

/// Liste des rendez-vous du jour sélectionné (timeline dans une carte).
class PrestataireAgendaDaySection extends StatelessWidget {
  const PrestataireAgendaDaySection({
    super.key,
    required this.dateLabel,
    required this.items,
    required this.onAccept,
    required this.onReject,
    required this.onMarkDone,
    required this.onItemTap,
    this.busyReservationId,
  });

  final String dateLabel;
  final List<PrestataireReservationItem> items;
  final void Function(String id) onAccept;
  final void Function(String id) onReject;
  final void Function(String id) onMarkDone;
  final void Function(String id) onItemTap;
  final String? busyReservationId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items.isEmpty
                          ? DiscPrestaAgenda.dayEmpty
                          : DiscPrestaAgenda.dayAppointments(items.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: AppFonts.body,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: AppFonts.body,
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            DiscoveryEmptyState(
              icon: Icons.calendar_today_outlined,
              title: DiscPrestaAgenda.dayEmptyTitle,
              body: DiscPrestaAgenda.dayEmptyBody,
              iconColor: theme.colorScheme.primary.withValues(alpha: 0.75),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                final busy = busyReservationId == item.id;
                final isLast = index == items.length - 1;

                return PrestataireAgendaReservationCard(
                  item: item,
                  busy: busy,
                  showTimelineConnector: !isLast,
                  onTap: () => onItemTap(item.id),
                  onAccept: busy
                      ? null
                      : () => onAccept(item.id),
                  onReject: busy
                      ? null
                      : () => onReject(item.id),
                  onMarkDone: busy
                      ? null
                      : () => onMarkDone(item.id),
                );
              },
            ),
        ],
      ),
    );
  }
}
