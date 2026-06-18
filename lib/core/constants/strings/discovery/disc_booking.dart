/// Flux réservation client (flow, erreurs métiers, listes personnelles).
abstract final class DiscBk {
  DiscBk._();

  static const missingPrestaTitle = 'Prestataire manquant';
  static const missingPrestaBody =
      'Retourne sur une fiche prestataire pour choisir un service.';
  static const svcLoadFailTitle = 'Services indisponibles';
  static const svcLoadFailBody =
      'Impossible de charger les services. Réessaie dans quelques instants.';
  static const noSvcsTitle = 'Aucun service disponible';
  static const noSvcsBody =
      'Ce prestataire n’a pas encore publié de service réservable.';
  static const selectedServiceLabel = 'Service sélectionné';
  static const stepService = '1. Choisis ton service';
  static const stepDate = '2. Choisis une date';
  static const stepDateSub =
      'Les jours colorés acceptent des créneaux de réservation.';
  static const stepSlots = '3. Choisis un créneau';
  static const noSlotsDay = 'Aucun créneau disponible pour cette date.';
  static const pickSlot = 'Choisis un créneau';
  static const btnConfirmShort = 'Confirmer';
  static const calMonthLabel = 'Mois';
  static const bookedSlotTooltip = 'Créneau déjà réservé';

  static const recapTitle = 'Récapitulatif';
  static const recapPresta = 'Prestataire';
  static const recapSvc = 'Service';
  static const recapDate = 'Date';
  static const recapTime = 'Heure';
  static const recapPrice = 'Prix';
  static const recapCta = 'Confirmer la réservation';
  static const recapCtaPay = 'Payer et confirmer';
  static const recapTrust =
      'Vérifie les informations ci-dessus. Ta réservation ne sera enregistrée qu’après confirmation.';
  static const recapCancelPolicy =
      'Tu pourras annuler depuis « Mes réservations » tant que le rendez-vous n’a pas eu lieu. '
      'En cas de paiement en ligne, le remboursement suit les règles Stripe.';
  static const doneBodyPaid =
      'Ton paiement est enregistré et ta réservation est confirmée. Le prestataire pourra la valider sous peu.';
  static const recapPrestaBadTitle = 'Prestataire introuvable';
  static const recapPrestaBadBody =
      'Impossible d’afficher le récapitulatif. Retourne à la fiche prestataire et réessaie.';

  static const doneAppBar = 'Réservation confirmée';
  static const doneHeadline = 'C’est confirmé !';
  static const doneBody =
      'Ta réservation est enregistrée. Le prestataire pourra la valider sous peu.';
  static const doneBodyQueued =
      'Ta réservation sera envoyée dès que tu seras reconnecté(e). '
      'Tu la retrouveras dans « Mes réservations » en attendant.';
  static const doneSeeMine = 'Voir mes réservations';

  static const emptyListTitle = 'Aucune réservation';
  static const emptyListBody = 'Tes prochaines réservations apparaîtront ici.';
  static const listErrTitle = 'Impossible de charger';
  static const listErrBody = 'Vérifie ta connexion et réessaie.';
  static const unknownSvc = 'Service';
  static const unknownPresta = 'Prestataire';

  static const reservationsSubtitle =
      'Tes rendez-vous à venir et ton historique.';
  static const tabFuture = 'À venir';
  static const tabPast = 'Passées';

  static const badgePending = 'En attente';
  static const pendingPrestaBanner =
      'En attente de confirmation par le prestataire. Tu seras notifié dès sa réponse.';
  static const rejectReasonTitle = 'Motif du refus';
  static const addToCalendar = 'Ajouter au calendrier';
  static const rebookSamePresta = 'Réserver à nouveau';
  static const calendarExportFail =
      'Impossible d’ouvrir le calendrier sur cet appareil.';
  static const badgeSyncPending = 'En attente d’envoi';
  static const badgeConfirmed = 'Confirmé';
  static const badgeDone = 'Terminé';
  static const badgeCancelled = 'Annulé';
  static const badgeUnknown = 'Statut';

  static const emptyFutureTitle =
      'Vous n’avez pas encore de réservation';
  static const emptyFutureBody =
      'Parcourez le catalogue et réservez votre première séance beauté.';
  static const emptyPastTitle = 'Aucune réservation passée';
  static const emptyPastBody =
      'Tes rendez-vous déjà effectués apparaîtront ici.';
  static const browsePresta = 'Rechercher un prestataire';
  static const bookingCreatedSnack =
      'Réservation confirmée. Retrouvez-la dans Mes réservations.';

  static const revokeLabel = 'Annuler';
  static const revokeAskTitle = 'Annuler la réservation ?';
  static const revokeAskBody =
      'Le prestataire sera informé si la réservation était déjà confirmée.';
  static const revokeYes = 'Oui, annuler';
  static const revokeFail =
      'Impossible d’annuler maintenant. Réessaie.';

  static const detailTitle = 'Ma réservation';
  static const detailNotFoundTitle = 'Réservation introuvable';
  static const detailNotFoundBody =
      'Cette réservation n’existe plus ou n’est plus accessible.';
  static const detailTapHint = 'Voir le détail';

  static const errSlotTaken =
      'Ce créneau vient d’être réservé par quelqu’un d’autre. Choisis un autre horaire.';
  static const errOffline =
      'Connexion perdue. Vérifie ton réseau et réessaie.';
  static const errNeedLogin =
      'Connecte-toi pour confirmer ta réservation.';
  static const errNeedClientProfile =
      'Profil client incomplet. Reconnecte-toi ou contacte le support.';
  static const errGenericSave =
      'Impossible de confirmer la réservation. Réessaie dans un instant.';
  static const errReferralDiscountExpired =
      'Ta remise parrainage n’est plus disponible. Recharge la page et réessaie.';
  static const errForbiddenBookingsLookup =
      'Tu ne peux pas consulter les réservations de ce profil.';
  static const cannotBookOwnTitle = 'Réservation impossible';
  static const cannotBookOwnBody =
      'Tu ne peux pas réserver tes propres services. Consulte ta fiche comme les autres clients, mais passe par un autre compte ou un autre prestataire pour réserver.';
  static const cannotBookOwnShort =
      'Tu ne peux pas réserver ton propre service.';
  static const errPrestaProfile =
      'Profil prestataire introuvable. Connecte-toi avec le bon compte.';
  static const errResMissing = 'Réservation introuvable.';
  static const errResBadState =
      'Impossible avec l’état actuel de la réservation.';
  static const errMarkDoneTooEarly =
      'Cette prestation ne peut pas encore être marquée terminée.';

  static String svcCountLabel(int count) =>
      '$count service${count > 1 ? 's' : ''} disponible${count > 1 ? 's' : ''}';

  static String continueWithSlot(String slot) => 'Confirmer - $slot';

  static const reminderDayBeforeTitle = 'Rappel – demain';
  static String reminderDayBeforeBody(String service, String time) =>
      '$service demain à $time';
  static const reminderTwoHoursTitle = 'Rappel – dans 2 h';
  static const reminderThirtyMinTitle = 'Rappel – dans 30 min';
  static const reminderFifteenMinTitle = 'Rappel – dans 15 min';
  static String reminderSoonBody(String service, String time) =>
      '$service à $time';

  static String selectionConfirmedLine({
    required String serviceName,
    required String date,
    required String slot,
  }) =>
      'Service confirmé : $serviceName, $date à $slot';
}
