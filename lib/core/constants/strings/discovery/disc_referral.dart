/// Parrainage client.
abstract final class DiscReferral {
  DiscReferral._();

  static const screenTitle = 'Parrainage';
  static const heroTitle = 'Invite tes amies';
  static const heroBody =
      'Partage ton code : quand une amie s’inscrit avec, elle bénéficie de −10 % sur sa prochaine réservation. '
      'À 3 filleules, tu débloques le badge Ambassadrice et −10 % sur ta prochaine résa.';
  static String benefitFriendDiscount(int percent) =>
      '−$percent % pour tes amies';
  static const benefitAmbassadorMilestone =
      'Badge Ambassadrice à 3 filleules';
  static const yourCode = 'Ton code';
  static const copyCode = 'Copier le code';
  static const copied = 'Code copié.';
  static const shareInvite = 'Partager mon invitation';
  static const shareMessage =
      'Rejoins-moi sur MadBeauty pour réserver tes soins beauté ! '
      'Utilise mon code parrain :';
  static const statInvites = 'Amies parrainées';
  static const enterCodeTitle = 'Tu as reçu un code ?';
  static const enterCodeHint = 'Ex. MB1A2B3C';
  static const applyCode = 'Valider le code';
  static const applyOk =
      'Code parrain enregistré. −10 % sur ta prochaine réservation !';
  static const applyErrInvalid = 'Ce code n’est pas valide.';
  static const applyErrSelf = 'Tu ne peux pas utiliser ton propre code.';
  static const applyErrUsed = 'Un code parrain a déjà été utilisé sur ce compte.';
  static const alreadyReferred = 'Tu as déjà activé un code parrain.';
  static const loadErr = 'Impossible de charger ton parrainage.';
  static const menuTitle = 'Parrainage';
  static const menuSubtitle = 'Invite tes amies et partage ton code';

  static const rewardsTitle = 'Tes récompenses';
  static const ambassadorBadge = 'Ambassadrice MadBeauty';
  static const ambassadorUnlocked =
      'Félicitations ! Tu as parrainé 3 amies. Le badge Ambassadrice est affiché sur ton profil.';
  static const milestoneProgress = 'Progression';
  static String invitesUntilAmbassador(int remaining) =>
      'Encore $remaining invitation${remaining > 1 ? 's' : ''} pour le badge Ambassadrice.';
  static const referredWelcome =
      'Bienvenue ! −10 % sur ta prochaine réservation est activé.';
  static const discountActiveTitle = 'Remise parrainage active';
  static String discountActiveBody(int percent) =>
      '−$percent % sur le prix de la prestation pour ta prochaine réservation.';
  static const discountUsedHint =
      'La remise s’applique automatiquement à la confirmation.';
}
