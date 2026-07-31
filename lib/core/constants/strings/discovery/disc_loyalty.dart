/// Fidélité client (points / prestation offerte).
abstract final class DiscLoyalty {
  DiscLoyalty._();

  static const screenTitle = 'Fidélité';
  static const menuTitle = 'Fidélité MadBeauty';
  static const menuSubtitle = 'Gagne des points, offre-toi une séance';

  static const heroTitle = 'Ta coiffure offerte';
  static const heroBody =
      'Réserve avec acompte dans l’app : à chaque prestation terminée, '
      'tu gagnes 2 points. À 200 points, une séance jusqu’à 50 € t’attend '
      'chez n’importe quel prestataire MadBeauty.';

  static const progressTitle = 'Ta progression';
  static String pointsLabel(int points) =>
      '$points pt${points > 1 ? 's' : ''}';
  static String goalLabel(int goal) => 'Objectif $goal pts';
  static String remaining(int n) =>
      n <= 0
          ? 'Récompense disponible !'
          : 'Encore $n pt${n > 1 ? 's' : ''} pour ta séance offerte';

  static const howTitle = 'Comment ça marche';
  static const howStep1 =
      '1. Tu paies un acompte via l’app (20 %).';
  static const howStep2 =
      '2. Le prestataire valide la prestation comme terminée → +2 points.';
  static const howStep3 =
      '3. À 200 points, tu utilises ta récompense (max 50 €) partout.';

  static const economicsHint =
      'Chaque acompte contribue à financer les séances offertes. '
      'La récompense est plafonnée à 50 €.';

  static const badgesTitle = 'Tes badges';
  static const badgeSteps = 'Premiers pas';
  static const badgeLoyal = 'Fidèle';
  static const badgeVip = 'VIP Beauté';
  static const badgeReward = 'Séance offerte';
  static String badgeThreshold(int pts) => '$pts pts';

  static const redeemReadyTitle = 'Récompense prête';
  static const redeemReadyBody =
      'Tu as assez de points. À la confirmation d’une réservation, '
      'active « Utiliser ma séance offerte » (jusqu’à 50 €).';
  static const redeemCta = 'Réserver maintenant';

  static const checkoutToggleTitle = 'Utiliser ma séance offerte';
  static String checkoutToggleSubtitle(int maxEur) =>
      '200 points · couverture jusqu’à $maxEur € chez ce prestataire';
  static const checkoutCoveredLine = 'Séance offerte (fidélité)';
  static const checkoutFullyFree =
      'Cette prestation est entièrement couverte par ta récompense.';
  static String checkoutPartialCover(String remaining) =>
      'Reste à régler : $remaining (hors couverture fidélité).';

  static const loadErr = 'Impossible de charger ta fidélité.';
  static const homeCardTitle = 'Fidélité';
  static String homeCardProgress(int points, int goal) =>
      '$points / $goal pts';
  static const homeCardReady = 'Séance offerte disponible';
  static const homeCardCta = 'Voir';

  static const errNotAvailable =
      'Récompense fidélité indisponible (points insuffisants).';
  static const errMismatch =
      'Le montant de la récompense ne correspond pas. Réessaie.';
  static const successRedeemed =
      'Séance offerte appliquée (−200 points).';
  static String rewardsUsed(int n) =>
      '$n séance${n > 1 ? 's' : ''} offerte${n > 1 ? 's' : ''} '
      'utilisée${n > 1 ? 's' : ''}';
}
