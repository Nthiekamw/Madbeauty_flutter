/// Notifications in-app / affichage boîte de réception locale.
abstract final class DiscNotif {
  DiscNotif._();

  static const sheetTitle = 'Notifications';
  static const clearAll = 'Tout effacer';
  static const markAllRead = 'Tout marquer comme lu';
  static const readLabel = 'Lu';
  static const unreadLabel = 'Non lu';
  static const emptyTitle = 'Pas encore de notification';
  static const emptyBody =
      'Quand vous recevez des alertes (réservations, confirmations…), '
      'elles apparaîtront ici. Activez aussi les notifications du téléphone pour ne rien manquer.';
  static const syncErr =
      'Impossible de charger l’historique des alertes. Réessaie.';

  static const bookingPendingTitle = 'Nouvelle demande de réservation';
  static const bookingConfirmedTitle = 'Réservation confirmée';
  static const bookingCancelledTitle = 'Réservation annulée';
  static const bookingDoneTitle = 'Prestation terminée';

  static const clientPendingTitle = 'Demande envoyée';
  static const clientConfirmedTitle = 'Réservation confirmée';
  static const clientCancelledTitle = 'Réservation annulée';
  static const clientDoneTitle = 'Prestation terminée';

  static String bookingBody({
    required String clientOrSalon,
    required String service,
  }) =>
      '$clientOrSalon · $service';

  static const prestataireLikeTitle = 'Nouveau like sur ton profil';
  static String prestataireLikeBody(String clientName) =>
      '$clientName a aimé ton profil MadBeauty.';

  static String prestataireReviewTitle(int note) => note <= 2
      ? 'Avis à améliorer sur ton profil'
      : 'Nouvel avis sur ton profil';

  static String prestataireReviewBody({
    required String clientName,
    required int note,
    String? comment,
  }) {
    final base = note <= 2
        ? '$clientName t\'a donné $note/5.'
        : '$clientName t\'a laissé $note/5 sur MadBeauty.';
    final trimmed = comment?.trim() ?? '';
    if (trimmed.isEmpty) return base;
    final preview = trimmed.length > 80
        ? '${trimmed.substring(0, 79)}…'
        : trimmed;
    return '$base « $preview »';
  }

  static const verificationApprovedTitle = 'Profil vérifié';
  static const verificationApprovedBody =
      'Ton profil prestataire est approuvé sur MadBeauty.';

  static const verificationRevokedTitle = 'Vérification à corriger';
  static String verificationRevokedBody(String reason) =>
      reason.trim().isEmpty
          ? 'L’équipe a retiré ta vérification. Consulte ton profil.'
          : 'Corrections demandées : $reason';

  static const bugReportNewTitle = 'Nouveau bug signalé';
  static String bugReportNewBody({
    required String category,
    required String title,
  }) =>
      '$category — $title';

  static const bugReportStatusTitle = 'Signalement de bug traité';
  static String bugReportStatusBody({
    required String title,
    required String statusLabel,
    String? reporterMessage,
  }) {
    final note = reporterMessage?.trim() ?? '';
    if (note.isNotEmpty) {
      return '« $title » : $statusLabel. $note';
    }
    return '« $title » a été $statusLabel par l’équipe.';
  }

  static const bugReportMessageTitle = 'Nouveau message sur ton bug';
  static const bugReportMessageAdminTitle = 'Nouveau message sur un bug';
  static String bugReportMessageBody(String preview) => preview;

  static const moderationPhotoRemovedTitle = 'Photo retirée';
  static const moderationPhotoFlaggedTitle = 'Contenu signalé';
  static const moderationAccountWarnedTitle = 'Avertissement MadBeauty';
  static String moderationEventBody(String message) =>
      message.trim().isEmpty
          ? 'Consulte ton profil prestataire pour plus de détails.'
          : message;
}
