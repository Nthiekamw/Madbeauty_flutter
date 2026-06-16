/// Statut d'accusé de réception pour les messages sortants.
enum ChatMessageReceiptStatus {
  /// Message enregistré côté serveur (✓).
  sent,

  /// Reçu par le destinataire (✓✓ gris).
  delivered,

  /// Lu par le destinataire (✓✓ bleu).
  read,
}

ChatMessageReceiptStatus chatOutgoingReceiptStatus({
  required bool isRead,
  DateTime? deliveredAt,
}) {
  if (isRead) return ChatMessageReceiptStatus.read;
  if (deliveredAt != null) return ChatMessageReceiptStatus.delivered;
  return ChatMessageReceiptStatus.sent;
}
