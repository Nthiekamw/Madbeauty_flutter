/// Créneaux de rappel avant un rendez-vous.
enum BookingReminderKind {
  dayBefore,
  twoHours,
  thirtyMinutes,
  fifteenMinutes,
}

/// Audience (évite les collisions d’ID notification client / prestataire).
enum BookingReminderAudience {
  client,
  prestataire;

  int get notificationIdOffset => switch (this) {
        client => 0,
        prestataire => 100000,
      };
}

/// ID de base par type de rappel (ajouté au hash réservation + [BookingReminderAudience.notificationIdOffset]).
const Map<BookingReminderKind, int> bookingReminderKindIdBase = {
  BookingReminderKind.dayBefore: 40000,
  BookingReminderKind.twoHours: 50000,
  BookingReminderKind.thirtyMinutes: 60000,
  BookingReminderKind.fifteenMinutes: 70000,
};

/// Statuts réservation éligibles aux rappels locaux.
bool bookingReminderStatusEligible(String statut) {
  final s = statut.trim().toLowerCase().replaceAll('é', 'e');
  return const {'confirmee', 'confirmed', 'validee', 'valide'}.contains(s);
}

/// Rappels encore programmables (dans le futur, avant le RDV).
List<({BookingReminderKind kind, DateTime at})> upcomingBookingReminderSlots({
  required DateTime appointmentAt,
  required DateTime now,
}) {
  final candidates = <({BookingReminderKind kind, DateTime at})>[
    (
      kind: BookingReminderKind.dayBefore,
      at: appointmentAt.subtract(const Duration(hours: 24)),
    ),
    (
      kind: BookingReminderKind.twoHours,
      at: appointmentAt.subtract(const Duration(hours: 2)),
    ),
    (
      kind: BookingReminderKind.thirtyMinutes,
      at: appointmentAt.subtract(const Duration(minutes: 30)),
    ),
    (
      kind: BookingReminderKind.fifteenMinutes,
      at: appointmentAt.subtract(const Duration(minutes: 15)),
    ),
  ];

  return [
    for (final slot in candidates)
      if (slot.at.isAfter(now) && slot.at.isBefore(appointmentAt)) slot,
  ];
}

int bookingReminderNotificationId({
  required String reservationId,
  required BookingReminderKind kind,
  required BookingReminderAudience audience,
}) {
  final hash = reservationId.hashCode.abs() % 10000;
  final base = bookingReminderKindIdBase[kind] ?? 0;
  return audience.notificationIdOffset + base + hash;
}
