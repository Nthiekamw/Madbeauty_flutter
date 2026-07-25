/// Tableau de bord prestataire synthétique.
abstract final class DiscPrestaDash {
  DiscPrestaDash._();

  static const pageSubtitle =
      'Demandes en attente, rendez-vous du jour et de la semaine.';
  static const quickAgenda = 'Agenda';
  static const quickHoraires = 'Horaires';
  static const quickClients = 'Clients';
  static const quickProfil = 'Profil';
  static const layoutCustomizeTitle = 'Personnalise ton tableau de bord';
  static const layoutCustomizeHint =
      'Maintiens ⋮⋮ puis glisse pour changer l’ordre des sections.';
  static const layoutOrganizeAction = 'Organiser';
  static const layoutModalDone = 'Terminé';
  static const layoutCustomizeEmpty =
      'Les sections apparaîtront ici une fois le tableau de bord chargé.';
  static const layoutHintDismiss = 'Compris';
  static const layoutDragHint = 'Glisser pour déplacer';
  static const layoutCollapse = 'Replier la section';
  static const layoutExpand = 'Déplier la section';
  static const sectionHero = 'Mon salon';
  static const sectionStats = 'Aperçu rapide';
  static const sectionBoutique = 'Boutique & offres';
  static const overviewTitle = 'Aperçu';
  static const overviewToday = 'Rendez-vous aujourd\'hui';
  static const overviewClientsMonth = 'Clients ce mois';
  static const overviewRevenueMonth = 'Revenus ce mois';
  static const overviewRevenueTotal = 'Revenus totaux';
  static const overviewBoutiqueOrders = 'Commandes boutique';
  static const overviewBoutiqueOrdersHint = 'À préparer ou remettre';
  static const overviewVsYesterday = 'vs hier';
  static const overviewVsLastMonth = 'vs mois dernier';
  static const welcome =
      'Ton profil est prêt à être visible par les clients.';
  static const profileMissing =
      'Complète ton profil professionnel pour commencer.';
  static const badgeComplete = 'Profil complet';
  static const badgeIncomplete = 'À compléter';
  static const profileIncompleteTitle = 'Profil incomplet';
  static const profileIncompleteBanner =
      'Reprends la complétion de ton profil professionnel';
  static const profileEnrichmentTitle = 'Profil à enrichir';
  static const profileEnrichmentBanner =
      'Confort, horaires ou réalisations : complète ton profil dans l’onglet Profil';
  static const statPending = 'En attente';
  static const statToday = 'Aujourd’hui';
  static const statWeek = 'Cette semaine';
  static const pendingEmptyTitle = 'Aucune demande';
  static const todayEmptyTitle = 'Journée libre';
  static const weekEmptyTitle = 'Semaine calme';
  static const manageSectionsTitle = 'Ma vitrine';
  static const editHoraires = 'Mes horaires';
  static const svcCount = 'Services';
  static const specialties = 'Spécialités';
  static const city = 'Ville';

  static const pendingTitle = 'Demandes en attente';
  static const pendingEmpty =
      'Aucune demande en attente. Les nouvelles réservations apparaîtront ici.';
  static const todayTitle = 'Aujourd\'hui';
  static const todayEmpty =
      'Aucun rendez-vous confirmé pour aujourd\'hui.';
  static const weekTitle = 'Cette semaine';
  static const weekEmpty =
      'Aucun autre rendez-vous confirmé cette semaine.';
  static const accept = 'Accepter';
  static const reject = 'Refuser';
  static const loadErr =
      'Impossible de charger les réservations. Réessaie.';
  static const actionOk = 'Réservation mise à jour.';
  static const actionErr =
      'Action impossible. Réessaie dans un instant.';
  static const unknownClient = 'Client';
  static const unknownService = 'Service';
  static const rejectConfirmTitle = 'Refuser cette demande ?';
  static const rejectConfirmBody =
      'Le client sera notifié que la réservation est annulée.';
}
