/// État messagerie client ↔ prestataire (fiche publique, navigation).
enum ClientPrestaChatAccessKind {
  /// Aucune réservation (ou uniquement annulées).
  noBooking,

  /// Réservation en attente de réponse du prestataire.
  awaitingPrestaResponse,

  /// Réservation confirmée ou terminée – chat autorisé.
  ready,
}

class ClientPrestaChatAccess {
  const ClientPrestaChatAccess._(this.kind, {this.bookingId});

  final ClientPrestaChatAccessKind kind;

  /// Identifiant de réservation lorsque [kind] est [ready] ou [awaitingPrestaResponse].
  final String? bookingId;

  factory ClientPrestaChatAccess.noBooking() =>
      const ClientPrestaChatAccess._(ClientPrestaChatAccessKind.noBooking);

  factory ClientPrestaChatAccess.awaiting({String? bookingId}) =>
      ClientPrestaChatAccess._(
        ClientPrestaChatAccessKind.awaitingPrestaResponse,
        bookingId: bookingId,
      );

  factory ClientPrestaChatAccess.ready(String bookingId) =>
      ClientPrestaChatAccess._(
        ClientPrestaChatAccessKind.ready,
        bookingId: bookingId,
      );
}
