/// Confort client et conditions de service (prestataire).
abstract final class DiscPrestaComfort {
  DiscPrestaComfort._();

  static const sectionComfortTitle = 'Confort client';
  static const sectionComfortHint =
      'Coche les propositions puis ajoute tes équipements ou attentions spécifiques.';
  static const sectionConditionsTitle = 'Conditions de service';
  static const sectionConditionsHint =
      'Choisis des modèles courants et complète avec tes règles personnalisées.';
  static const addCustomComfortLabel = 'Ajouter un confort';
  static const addCustomComfortHint = 'Ex. Salon non-fumeur, musique douce…';
  static const addCustomConditionLabel = 'Ajouter une condition';
  static const addCustomConditionHint =
      'Ex. Pas de tresses sur cheveux fragilisés sans diagnostic.';
  static const addAction = 'Ajouter';
  static const emptyComfort =
      'Aucun confort renseigné pour le moment.';
  static const emptyConditions =
      'Aucune condition de service renseignée.';

  static const wifi = 'Wi-Fi gratuit';
  static const parking = 'Parking à proximité';
  static const pmr = 'Accès PMR';
  static const refreshments = 'Boissons à disposition';
  static const climate = 'Climatisation';
  static const kids = 'Accueil enfants';
  static const vegan = 'Produits bio / vegan';
  static const consultation = 'Consultation gratuite';
  static const flexPayment = 'Paiement flexible';

  static const condCancel24h = 'Annulation gratuite jusqu’à 24 h avant';
  static const condCancel48h = 'Annulation gratuite jusqu’à 48 h avant';
  static const condLate15 = 'Retard de plus de 15 min : créneau annulé';
  static const condNoDeposit = 'Pas d’acompte à la réservation';
  static const condDeposit30 = 'Acompte de 20 % à la réservation';
  static const condHygiene =
      'Cheveux propres, sans maquillage excessif ni produits lourds';
  static const condArriveEarly = 'Arriver 5 min avant l’heure du rendez-vous';
  static const condMinorGuardian = 'Mineures accompagnées d’un adulte';

  static const menuTitle = 'Confort & conditions';
  static const menuHint =
      'Équipements salon et règles pour tes clientes';
  static const editTitle = 'Modifier confort & conditions';
}
