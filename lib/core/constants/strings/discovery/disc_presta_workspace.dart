/// En-tête et cartes communes (agenda, clients, profil prestataire).
abstract final class DiscPrestaWorkspace {
  DiscPrestaWorkspace._();

  static String greeting(String name) => 'Bonjour $name ! 👋';
  static const spaceLabel = 'Espace prestataire 💇';
  static const railSpaceLabel = 'Espace prestataire';
  static const dashboardWebSubtitle =
      'Vue d’ensemble de ton activité et de tes demandes';
  static const refreshTooltip = 'Actualiser';
  static const refreshShort = 'Actualiser';
  static const paymentsTooltip =
      'Abonnement MadBeauty (catalogue) — distinct de l’encaissement des prestations';
  static const paymentsShort = 'Abonnement';
  static const notificationsTooltip = 'Notifications';
  static const notificationsShort = 'Alertes';
  static const messagesTooltip = 'Messages';
  static const messagesShort = 'Messages';
  static const messagesInboxSubtitle =
      'Échanges liés à tes réservations acceptées';
  /// Sous-titre court de l'en-tête (onglet Messages).
  static const messagesInboxHeaderSubtitle = 'Messages clients';
  static const agendaSubtitle = 'Planning et demandes de réservation';
  static const clientsSubtitle = 'Historique et fidélisation';
  static const profileHeaderSubtitle = 'Compte, paiements et réglages pro';

  static const completionTitle =
      'Complétez votre profil pour recevoir des clients';
  static const completionBody =
      'Une fiche complète inspire confiance et améliore ta visibilité sur MadBeauty.';
  static const completionProgress = 'Progression';

  static const agendaTabUpcoming = 'À venir';
  static const agendaTabPast = 'Passés';
  static const agendaTabCancelled = 'Annulés';
  static const agendaNewCta = 'Nouveau';

  static const clientsSearchHint = 'Rechercher un client…';
  static const clientsTabClients = 'Clients';
  static const clientsTabReviews = 'Avis';
  static String clientsCount(int n) => 'Clients ($n)';
  static String reviewsCount(int n) => 'Avis ($n)';
  static const loyalBadge = 'Fidèle';
  static String lastVisit(String date) => 'Dernière visite · $date';

  static const profileSummaryFree = 'Gratuit';
  static const profileMenuTitle = 'Mon compte';
}
