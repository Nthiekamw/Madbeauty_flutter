import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../logic/reservation_calendar_export.dart';

/// Bottom sheet : Google Calendar ou fichier .ics (Apple / Outlook).
Future<void> showAddToCalendarSheet(
  BuildContext context, {
  required String reservationId,
  required String title,
  required DateTime start,
  required int durationMinutes,
  String? location,
  String? details,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DiscBk.addToCalendarTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DiscBk.addToCalendarBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.event_available_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: const Text(DiscBk.addToGoogleCalendar),
                subtitle: const Text(DiscBk.addToGoogleCalendarHint),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final ok =
                      await ReservationCalendarExport.openInGoogleCalendar(
                    title: title,
                    start: start,
                    durationMinutes: durationMinutes,
                    location: location,
                    details: details,
                  );
                  if (!context.mounted) return;
                  if (!ok) {
                    AppSnackBar.show(
                      context,
                      message: DiscBk.calendarExportFail,
                      kind: AppSnackKind.error,
                    );
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.secondary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                title: const Text(DiscBk.addToAppleOutlook),
                subtitle: const Text(DiscBk.addToAppleOutlookHint),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final ok = await ReservationCalendarExport.shareIcsFile(
                    uid: reservationId,
                    title: title,
                    start: start,
                    durationMinutes: durationMinutes,
                    location: location,
                    description: details,
                  );
                  if (!context.mounted) return;
                  if (!ok) {
                    AppSnackBar.show(
                      context,
                      message: DiscBk.calendarExportFail,
                      kind: AppSnackKind.error,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
