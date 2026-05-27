import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../../booking/logic/booking_formatters.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import '../models/prestataire_reservation_item.dart';

/// Corps de l’écran détail réservation (infos + actions).
class PrestataireReservationDetailBody extends StatelessWidget {
  const PrestataireReservationDetailBody({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onReject,
    required this.onMarkDone,
    this.onMessage,
    this.busy = false,
  });

  final PrestataireReservationItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkDone;
  final VoidCallback? onMessage;
  final bool busy;

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
    final status = clientReservationUiStatusFromStatut(item.statut);
    final chip = chipColorsForReservationStatus(theme.colorScheme, status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        DiscoverySurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.14,
                ),
                child: Text(
                  _initials(item.clientName),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.clientName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.serviceName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: chip.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  clientReservationStatusLabel(status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: chip.foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        DiscoverySurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: DiscPrestaReservation.labelDate,
                value: formatBookingDate(item.dateHeure),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.schedule_rounded,
                label: DiscPrestaReservation.labelTime,
                value: formatBookingTime(item.dateHeure),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.spa_outlined,
                label: DiscPrestaReservation.labelService,
                value: item.serviceName,
              ),
            ],
          ),
        ),
        if (item.notesClient?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          DiscoverySurfaceCard(
            padding: const EdgeInsets.all(16),
            child: _DetailRow(
              icon: Icons.chat_bubble_outline_rounded,
              label: DiscPrestaReservation.labelClientNote,
              value: item.notesClient!.trim(),
              multiline: true,
            ),
          ),
        ],
        if (item.notesPrestataire?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          DiscoverySurfaceCard(
            padding: const EdgeInsets.all(16),
            child: _DetailRow(
              icon: Icons.info_outline_rounded,
              label: DiscPrestaReservation.labelRejectReason,
              value: item.notesPrestataire!.trim(),
              multiline: true,
              tone: theme.colorScheme.error,
            ),
          ),
        ],
        if (status == ClientReservationUiStatus.pending) ...[
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: busy ? null : onMarkDone,
              child: Text(busy ? '…' : DiscPrestaAgenda.markDone),
            ),
          ),
        ],
        if (onMessage != null &&
            status != ClientReservationUiStatus.cancelled) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy ? null : onMessage,
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text(DiscChat.openChat),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
    this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool multiline;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tone ?? theme.colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  color: color,
                  height: multiline ? 1.4 : 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
