/// État messagerie client ↔ prestataire (fiche publique, navigation).
enum ClientPrestaChatAccessKind {
  /// Aucune réservation (ou uniquement annulées) — devis / conseil possible.
  noBooking,

  /// Réservation en attente de réponse du prestataire.
  awaitingPrestaResponse,

  /// Réservation confirmée ou terminée – chat autorisé.
  ready,

  /// Fil devis / conseil (hors réservation).
  inquiry,
}

class ClientPrestaChatAccess {
  const ClientPrestaChatAccess._(
    this.kind, {
    this.bookingId,
    this.conversationId,
  });

  final ClientPrestaChatAccessKind kind;

  /// Identifiant de réservation lorsque [kind] est [ready] ou [awaitingPrestaResponse].
  final String? bookingId;

  /// Conversation inquiry éventuelle.
  final String? conversationId;

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

  factory ClientPrestaChatAccess.inquiry({String? conversationId}) =>
      ClientPrestaChatAccess._(
        ClientPrestaChatAccessKind.inquiry,
        conversationId: conversationId,
      );
}
