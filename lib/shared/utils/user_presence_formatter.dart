import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';

/// Libellés « En ligne » / « Vu il y a… » pour le chat.
abstract final class UserPresenceFormatter {
  UserPresenceFormatter._();

  static const onlineThreshold = Duration(minutes: 2);

  static bool isOnline(DateTime? lastSeenAt, {DateTime? now}) {
    if (lastSeenAt == null) return false;
    final reference = now ?? DateTime.now();
    return reference.difference(lastSeenAt.toLocal()) <= onlineThreshold;
  }

  static String label(DateTime? lastSeenAt, {DateTime? now}) {
    if (lastSeenAt == null) return DiscChat.presenceUnknown;
    final seen = lastSeenAt.toLocal();
    final reference = (now ?? DateTime.now()).toLocal();
    final diff = reference.difference(seen);

    if (diff <= onlineThreshold) return DiscChat.presenceOnline;
    if (diff.inMinutes < 1) return DiscChat.presenceJustNow;
    if (diff.inMinutes < 60) {
      return DiscChat.presenceMinutesAgo(diff.inMinutes);
    }
    if (diff.inHours < 24) {
      return DiscChat.presenceHoursAgo(diff.inHours);
    }

    final today = DateTime(reference.year, reference.month, reference.day);
    final seenDay = DateTime(seen.year, seen.month, seen.day);
    if (seenDay == today.subtract(const Duration(days: 1))) {
      return DiscChat.presenceYesterdayAt(
        DateFormat('HH:mm', 'fr_FR').format(seen),
      );
    }

    return DiscChat.presenceOnDate(
      DateFormat('d MMM • HH:mm', 'fr_FR').format(seen),
    );
  }
}
