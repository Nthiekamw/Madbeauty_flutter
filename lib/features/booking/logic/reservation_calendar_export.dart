import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Export d'une réservation vers le calendrier (Google Calendar via URL).
abstract final class ReservationCalendarExport {
  ReservationCalendarExport._();

  static String googleCalendarUrl({
    required String title,
    required DateTime start,
    required int durationMinutes,
    String? location,
    String? details,
  }) {
    final end = start.add(Duration(minutes: durationMinutes));
    final fmt = DateFormat("yyyyMMdd'T'HHmmss");
    final dates =
        '${fmt.format(start.toUtc())}/${fmt.format(end.toUtc())}';
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
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

