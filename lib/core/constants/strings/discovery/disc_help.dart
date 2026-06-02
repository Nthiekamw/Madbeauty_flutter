/// Centre d'aide et politiques.
abstract final class DiscHelp {
  DiscHelp._();

  static const screenTitle = 'Aide & infos';
  static const sectionBooking = 'Réservations';
  static const sectionChat = 'Messagerie';
  static const sectionReferral = 'Parrainage';
  static const sectionPayment = 'Paiement';

  static const bookingFlowTitle = 'Comment réserver ?';
  static const bookingFlowBody =
      '1. Choisis un prestataire et un service.\n'
      '2. Sélectionne un créneau.\n'
      '3. Paie si le prestataire accepte le paiement en ligne.\n'
      '4. Attends la confirmation du prestataire : le chat s’ouvre ensuite.';

  static const cancelPolicyTitle = 'Annulation';
  static const cancelPolicyBody =
      'Tu peux annuler une réservation en attente ou confirmée depuis '
      '« Mes réservations ». En cas de refus par le prestataire, tu seras '
      'informé du motif. Les remboursements suivent les règles Stripe '
      'lorsque un paiement en ligne a été effectué.';

  static const chatPolicyTitle = 'Chat sécurisé';
  static const chatPolicyBody =
      'Pour ta sécurité, les numéros de téléphone, e-mails et liens externes '
      'ne peuvent pas être envoyés dans le chat. Organise ton rendez-vous '
      'via MadBeauty.';

  static const referralTitle = 'Inviter une amie';
  static const referralBody =
      'Dans ton profil, ouvre « Parrainage » pour copier ou partager ton code. '
      'Ton amie le saisit à l’inscription ou après connexion.';

  static const paymentTitle = 'Paiement en ligne';
  static const paymentBody =
      'Le paiement sécurise ta réservation. Le prestataire reçoit les fonds '
      'après la prestation selon les règles Stripe Connect.';

  static const waitlistTitle = 'Alerte créneau';
  static const waitlistBody =
      'Si un jour est complet, tu peux demander une alerte depuis l’écran de réservation. '
      'Tu recevras une notification push lorsqu’un créneau se libère (annulation ou refus).';

  static const reportTitle = 'Signaler un contenu';
  static const reportBody =
      'Depuis une fiche prestataire ou un chat, utilise « Signaler » pour nous signaler '
      'un comportement inapproprié.';

  static const contactSupport = 'Une question ? Contacte le support via ton e-mail d’inscription.';
}
