/// Médiation / litiges réservation.
abstract final class DiscDispute {
  DiscDispute._();

  static const openAction = 'Ouvrir une médiation';
  static const viewAction = 'Voir la médiation';
  static const sheetTitle = 'Ouvrir une médiation';
  static const sheetBody =
      'Décris le problème lié à cette réservation. '
      'MadBeauty pourra intervenir entre toi et l’autre partie.';
  static const reasonLabel = 'Motif';
  static const summaryLabel = 'Résumé (optionnel)';
  static const summaryHint =
      'Explique brièvement ce qu’il s’est passé…';
  static const submit = 'Envoyer la demande';
  static const submitOk = 'Médiation ouverte.';
  static const submitErr =
      'Impossible d’ouvrir la médiation. Réessaie plus tard.';

  static const reasonNoShow = 'Absence / no-show';
  static const reasonDeposit = 'Acompte / paiement';
  static const reasonQuality = 'Qualité de la prestation';
  static const reasonRefund = 'Remboursement';
  static const reasonOther = 'Autre';

  static String reasonLabelOf(String reason) => switch (reason) {
        'no_show' => reasonNoShow,
        'deposit' => reasonDeposit,
        'quality' => reasonQuality,
        'refund' => reasonRefund,
        'other' => reasonOther,
        _ => reason,
      };

  static const statusOpen = 'Ouvert';
  static const statusUnderReview = 'En examen';
  static const statusFavorClient = 'Résolu — client';
  static const statusFavorPresta = 'Résolu — prestataire';
  static const statusClosed = 'Classé';

  static String statusLabelOf(String status) => switch (status) {
        'open' => statusOpen,
        'under_review' => statusUnderReview,
        'resolved_favor_client' => statusFavorClient,
        'resolved_favor_presta' => statusFavorPresta,
        'closed' => statusClosed,
        _ => status,
      };

  static const detailTitle = 'Médiation';
  static const detailLoadErr = 'Impossible de charger cette médiation.';
  static const detailNotFoundTitle = 'Médiation introuvable';
  static const detailNotFoundBody =
      'Ce dossier n’existe pas ou tu n’y as pas accès.';
  static const summarySection = 'Résumé';
  static const resolutionSection = 'Décision';
  static const messagesTitle = 'Échanges';
  static const messagesEmpty =
      'Aucun message pour l’instant. Décris ta situation.';
  static const messageHint = 'Écrire un message…';
  static const messageSendErr = 'Impossible d’envoyer le message.';
  static const messagesClosed =
      'Cette médiation est close : tu ne peux plus écrire.';
  static const roleClient = 'Client';
  static const rolePrestataire = 'Prestataire';
  static const roleAdmin = 'MadBeauty';

  static String roleLabelOf(String role) => switch (role) {
        'client' => roleClient,
        'prestataire' => rolePrestataire,
        'admin' => roleAdmin,
        _ => role,
      };

  static const errAlreadyOpen =
      'Une médiation est déjà en cours pour cette réservation.';
  static const errNotEligible =
      'La médiation n’est possible que pour une réservation '
      'confirmée, terminée ou annulée.';
  static const errForbidden = 'Tu n’as pas accès à cette action.';
  static const errNotFound = 'Réservation ou médiation introuvable.';

  static const adminScreenTitle = 'Médiations';
  static const adminIntroTitle = 'Litiges réservation';
  static const adminIntroBody =
      'Ouvre un dossier pour examiner les échanges, '
      'puis tranche en faveur du client, du prestataire ou classe.';
  static const adminFilterOpen = 'Ouverts';
  static const adminFilterAll = 'Tous';
  static const adminEmpty = 'Aucune médiation pour le moment.';
  static const adminHubTitle = 'Médiations réservation';
  static const adminHubHint =
      'Litiges acompte, no-show, qualité et remboursements.';
  static const adminNotesLabel = 'Note interne (optionnelle)';
  static const adminResolutionLabel = 'Message de décision (optionnel)';
  static const adminResolutionHint =
      'Visible par les parties dans le dossier.';
  static const adminActionReview = 'Prendre en charge';
  static const adminActionFavorClient = 'Trancher — client';
  static const adminActionFavorPresta = 'Trancher — prestataire';
  static const adminActionClose = 'Classer';
  static const adminUpdated = 'Médiation mise à jour.';
  static const adminUpdateErr =
      'Impossible de mettre à jour cette médiation.';
  static const adminDetailTitle = 'Dossier médiation';
  static const openedByClient = 'Ouvert par le client';
  static const openedByPresta = 'Ouvert par le prestataire';

  static String openedByLabel(String openedBy) => switch (openedBy) {
        'client' => openedByClient,
        'prestataire' => openedByPresta,
        _ => openedBy,
      };
}
