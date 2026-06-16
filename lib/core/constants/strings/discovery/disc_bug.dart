/// Signalement de bugs techniques.
abstract final class DiscBug {
  DiscBug._();

  static const actionReport = 'Signaler un bug';
  static const actionReportHint =
      'Décris un problème technique pour que l’équipe le corrige.';
  static const actionMyReports = 'Mes signalements de bugs';
  static const actionNewReport = 'Nouveau signalement';
  static const actionNewReportHint =
      'Décris le bug rencontré : l’équipe sera notifiée.';
  static const hubSubtitle =
      'Consulte tes signalements ou en crée un nouveau.';

  static const screenTitle = 'Signaler un bug';
  static const newReportTitle = 'Nouveau signalement';
  static const newReportSubtitle =
      'Décris le problème le plus précisément possible. '
      'L’équipe MadBeauty sera notifiée.';

  static const fieldCategory = 'Catégorie';
  static const fieldTitle = 'Titre';
  static const fieldTitleHint = 'Ex. Impossible de réinitialiser mon mot de passe';
  static const fieldDescription = 'Description';
  static const fieldDescriptionHint =
      'Que s’est-il passé ? Quel résultat attendais-tu ?';
  static const fieldSteps = 'Étapes pour reproduire (optionnel)';
  static const fieldStepsHint =
      '1. Ouvrir l’app\n2. Aller sur…\n3. Cliquer sur…';
  static const fieldScreenshot = 'Capture d’écran (optionnel)';
  static const fieldScreenshotAdd = 'Ajouter une capture';
  static const fieldScreenshotRemove = 'Retirer la capture';

  static const categoryAuth = 'Connexion / compte';
  static const categoryBooking = 'Réservation';
  static const categoryPayment = 'Paiement';
  static const categoryMessaging = 'Messagerie';
  static const categoryProfile = 'Profil';
  static const categoryOther = 'Autre';

  static const submit = 'Envoyer le signalement';
  static const submitSuccess =
      'Merci ! Ton signalement a été transmis à l’équipe.';
  static const submitErr =
      'Impossible d’envoyer le signalement. Réessaie plus tard.';

  static const validationTitle = 'Le titre doit contenir au moins 3 caractères.';
  static const validationDescription =
      'La description doit contenir au moins 10 caractères.';
  static const loginRequired =
      'Connecte-toi pour signaler un bug.';

  static const myReportsTitle = 'Mes signalements';
  static const myReportsSectionTitle = 'Mes signalements';
  static const myReportsEmpty =
      'Tu n’as pas encore signalé de bug.';
  static const myReportsEmptyBody =
      'Utilise le bouton ci-dessus pour créer ton premier signalement.';

  static String myReportsCountLabel(int count) {
    if (count <= 0) return myReportsEmpty;
    if (count == 1) return '1 signalement';
    return '$count signalements';
  }
  static const statusPending = 'En attente';
  static const statusInProgress = 'En cours';
  static const statusResolved = 'Résolu';
  static const statusClosed = 'Classé';

  static String statusLabel(String status) => switch (status) {
        'pending' => statusPending,
        'in_progress' => statusInProgress,
        'resolved' => statusResolved,
        'closed' => statusClosed,
        _ => status,
      };

  static String categoryLabel(String category) => switch (category) {
        'auth' => categoryAuth,
        'booking' => categoryBooking,
        'payment' => categoryPayment,
        'messaging' => categoryMessaging,
        'profile' => categoryProfile,
        'other' => categoryOther,
        _ => category,
      };

  static const adminScreenTitle = 'Bugs signalés';
  static const adminIntroTitle = 'Signalements techniques';
  static const adminIntroBody =
      'Les utilisateurs signalent ici les dysfonctionnements de l’application. '
      'Change le statut pour informer le reporter par notification.';
  static const adminFilterPending = 'À traiter';
  static const adminFilterAll = 'Tous';
  static const adminEmpty = 'Aucun bug signalé pour le moment.';
  static const adminNotesLabel = 'Note interne (optionnelle)';
  static const adminReporterMessageLabel =
      'Message personnalisé à l’utilisateur';
  static const adminReporterMessageHint =
      'Visible par l’utilisateur et envoyé par notification à la résolution.';
  static const adminOpenChat = 'Discuter';
  static const chatTitleReporter = 'Discussion avec l’équipe';
  static const chatTitleAdmin = 'Discussion du bug';
  static const chatAdminHint =
      'Échange avec l’utilisateur pour comprendre ou corriger le problème.';
  static const chatEmpty =
      'Aucun message pour l’instant. Envoie le premier message.';
  static const chatEmptyReporterHint =
      'L’équipe te répondra ici.';
  static const chatSendErr = 'Impossible d’envoyer le message.';
  static const chatLoadErr = 'Impossible de charger la discussion.';
  static const openChat = 'Ouvrir la discussion';
  static const tileOpenDiscussion = 'Discuter avec l’équipe';
  static const adminActionInProgress = 'Prendre en charge';
  static const adminActionResolved = 'Marquer résolu';
  static const adminActionClosed = 'Classer sans suite';
  static const adminUpdated = 'Signalement mis à jour.';
  static const adminUpdateErr =
      'Impossible de mettre à jour ce signalement.';
  static const chatCloseAction = 'Clôturer la discussion';
  static const chatCloseDialogTitle = 'Clôturer la discussion ?';
  static const chatCloseDialogBody =
      'L’utilisateur ne pourra plus envoyer de messages. '
      'Tu peux lui laisser un dernier message.';
  static const chatCloseFinalMessageLabel =
      'Dernier message à l’utilisateur (optionnel)';
  static const chatCloseAsResolved = 'Marquer résolu';
  static const chatCloseAsClosed = 'Classer sans suite';
  static const chatCloseConfirm = 'Clôturer';
  static const chatCloseSuccess = 'Discussion clôturée.';
  static const chatCloseErr =
      'Impossible de clôturer cette discussion.';
  static const chatClosedBanner =
      'Cette discussion est clôturée. Aucun nouveau message ne peut être envoyé.';
  static const chatClosedInputHint = 'Discussion clôturée';
}
