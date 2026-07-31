import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'reservation_calendar_ics.dart';

/// Export réservation → Google Calendar (URL) ou fichier `.ics` (Apple / Outlook).
abstract final class ReservationCalendarExport {
  ReservationCalendarExport._();

  /// Google Calendar : dates en UTC avec suffixe Z.
  static String googleCalendarUrl({
    required String title,
    required DateTime start,
    required int durationMinutes,
    String? location,
    String? details,
  }) {
    final startUtc = start.toUtc();
    final endUtc =
        startUtc.add(Duration(minutes: durationMinutes.clamp(1, 24 * 60)));
    final fmt = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    final dates = '${fmt.format(startUtc)}/${fmt.format(endUtc)}';
    final params = <String, String>{
      'action': 'TEMPLATE',
      'text': title,
      'dates': dates,
      if (location != null && location.trim().isNotEmpty)
        'location': location.trim(),
      if (details != null && details.trim().isNotEmpty)
        'details': details.trim(),
    };
    final query = params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
    return 'https://calendar.google.com/calendar/render?$query';
  }

  static Future<bool> openInGoogleCalendar({
    required String title,
    required DateTime start,
    required int durationMinutes,
    String? location,
    String? details,
  }) async {
    final uri = Uri.parse(
      googleCalendarUrl(
        title: title,
        start: start,
        durationMinutes: durationMinutes,
        location: location,
        details: details,
      ),
    );
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Contenu iCalendar (RFC 5545) pour Apple Calendar / Outlook / etc.
  static String buildIcs({
    required String uid,
    required String title,
    required DateTime start,
    required int durationMinutes,
    String? location,
    String? description,
  }) {
    final startUtc = start.toUtc();
    final endUtc =
        startUtc.add(Duration(minutes: durationMinutes.clamp(1, 24 * 60)));
    final stamp = DateTime.now().toUtc();
    final fmt = DateFormat("yyyyMMdd'T'HHmmss'Z'");

    String esc(String raw) => raw
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');

    final buf = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//MadBeauty//Booking//FR')
      ..writeln('CALSCALE:GREGORIAN')
      ..writeln('METHOD:PUBLISH')
      ..writeln('BEGIN:VEVENT')
      ..writeln('UID:$uid@madbeauty')
      ..writeln('DTSTAMP:${fmt.format(stamp)}')
      ..writeln('DTSTART:${fmt.format(startUtc)}')
      ..writeln('DTEND:${fmt.format(endUtc)}')
      ..writeln('SUMMARY:${esc(title)}');
    if (location != null && location.trim().isNotEmpty) {
      buf.writeln('LOCATION:${esc(location.trim())}');
    }
    if (description != null && description.trim().isNotEmpty) {
      buf.writeln('DESCRIPTION:${esc(description.trim())}');
    }
    buf
      ..writeln('END:VEVENT')
      ..writeln('END:VCALENDAR');
    return buf.toString();
  }

  /// Partage le `.ics` (mobile) ; sur web ouvre Google Calendar.
  static Future<bool> shareIcsFile({
    required String uid,
    required String title,
    required DateTime start,
    required int durationMinutes,
    String? location,
    String? description,
  }) async {
    if (kIsWeb) {
      return openInGoogleCalendar(
        title: title,
        start: start,
        durationMinutes: durationMinutes,
        location: location,
        details: description,
      );
    }

    try {
      final ics = buildIcs(
        uid: uid,
        title: title,
        start: start,
        durationMinutes: durationMinutes,
        location: location,
        description: description,
      );
      final safeName = uid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      return shareIcsNativeFile(
        fileName: 'madbeauty_$safeName.ics',
        icsContent: ics,
        subject: title,
      );
    } catch (_) {
      return false;
    }
  }
}
