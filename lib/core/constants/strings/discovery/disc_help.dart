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
      '3. Confirme ta réservation.\n'
      '4. Attends la confirmation du prestataire : le chat s’ouvre ensuite.';

  static const cancelPolicyTitle = 'Annulation';
  static const cancelPolicyBody =
      'Tu peux annuler une réservation en attente ou confirmée depuis '
      '« Mes réservations ». En cas de refus par le prestataire, tu seras '
      'informé du motif.';

  static const chatPolicyTitle = 'Chat sécurisé';
  static const chatPolicyBody =
      'Pour ta sécurité, les numéros de téléphone, e-mails et liens externes '
      'ne peuvent pas être envoyés dans le chat. Organise ton rendez-vous '
      'via MadBeauty.';

  static const referralTitle = 'Inviter une amie';
  static const referralBody =
      'Dans ton profil, ouvre « Parrainage » pour copier ou partager ton code. '
      'Ton amie le saisit à l’inscription ou après connexion.';

  static const paymentTitle = 'Règlement sur place';
  static const paymentBody =
      'Le montant de la prestation se règle directement chez le prestataire le jour J. '
      'Aucun paiement dans l’application.';

  static const waitlistTitle = 'Alerte créneau';
  static const waitlistBody =
      'Si un jour est complet, tu peux demander une alerte depuis l’écran de réservation. '
      'Tu recevras une notification push lorsqu’un créneau se libère (annulation ou refus).';

  static const reportTitle = 'Signaler un contenu';
  static const reportBody =
      'Depuis une fiche prestataire ou un chat, utilise « Signaler » pour nous signaler '
      'un comportement inapproprié.';

  static const contactSupport = 'Une question ? Contacte le support via ton e-mail d’inscription.';

  static const sectionLegal = 'Informations légales';
  static const privacyPolicyTitle = 'Politique de confidentialité';
  static const privacyPolicyHint =
      'Données collectées, finalités, sous-traitants et tes droits (RGPD).';
  static const childSafetyTitle = 'Sécurité des enfants';
  static const childSafetyHint =
      'Protection des mineurs, signalement et droits des parents (18+).';
  static const openPrivacyPolicyErr =
      'Impossible d’ouvrir la politique de confidentialité. Réessaie plus tard.';
  static const openChildSafetyErr =
      'Impossible d’ouvrir la page sécurité des enfants. Réessaie plus tard.';
}
