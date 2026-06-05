/// Moyens de paiement prestataire (abonnement + encaissement).
abstract final class DiscPaymentMethods {
  DiscPaymentMethods._();

  static const sectionTitle = 'Moyens de paiement';
  static const sectionSubtitle =
      'Abonnement plateforme et encaissement de tes prestations.';
  static const clientSectionSubtitle =
      'Cartes enregistrées pour les acomptes et paiements en ligne.';
  static const accountMenuHint =
      'Carte d’abonnement et compte pour recevoir tes paiements';
  static const clientAccountMenuHint =
      'Gérer tes cartes bancaires enregistrées';
  static const clientCardsTitle = 'Mes cartes bancaires';
  static const clientCardsHint =
      'Utilisées lors des réservations avec acompte ou paiement en ligne.';
  static const clientCardsManage = 'Gérer mes moyens de paiement';

  static const subscriptionTitle = 'Abonnement MadBeauty';
  static const subscriptionHint =
      'Carte bancaire pour ton abonnement professionnel (catalogue).';
  static const subscriptionManage = 'Gérer mon moyen de paiement';
  static const subscriptionSubscribe = 'S’abonner';
  static const subscriptionViewOffers = 'Voir les offres';
  static const subscriptionStatusActive = 'Abonnement actif';
  static const subscriptionStatusNone = 'Aucun abonnement actif';
  static const subscriptionStatusPastDue =
      'Paiement en retard — mets à jour ta carte';

  static const payoutTitle = 'Recevoir mes paiements';
  static const payoutHint =
      'Compte bancaire pour être payée après chaque prestation.';
  static const payoutConfigure = 'Configurer mon compte';
  static const payoutContinue = 'Continuer la configuration';
  static const payoutRefresh = 'Actualiser le statut';
  static const payoutActive = 'Compte actif — tu peux encaisser';
  static const payoutPending = 'Configuration en cours';
  static const payoutNotStarted = 'Non configuré';

  static const distinctionNote =
      'L’abonnement paie MadBeauty · Recevoir mes paiements te verse l’argent des réservations.';
  static const portalOpened =
      'Ouvre le portail Stripe pour modifier ta carte ou ta facturation.';
  static const portalErr = 'Impossible d’ouvrir le portail de paiement';
  static const browserErr =
      'Impossible d’ouvrir la page. Réessaie dans un instant.';
  static const unavailable = 'Paiement indisponible (configuration Stripe)';
  static const statusUpdated = 'Statut mis à jour.';
}
