/// Écran profil prestataire (onglet shell).
abstract final class DiscPrestaProfile {
  DiscPrestaProfile._();

  static const title = 'Profil';
  static const pageSubtitle =
      'Vitrine, horaires, fiche publique et compte.';
  static const editTitle = 'Profil professionnel';
  static const incompleteTitle = 'Profil incomplet';
  static const incompleteBody =
      'Complète ton salon : photo, bio, adresse, spécialités, services et au moins une photo de réalisation pour apparaître dans le catalogue.';
  static const incompleteCta = 'Compléter mon profil';
  static const sectionPro = 'Gérer mon activité';
  static const sectionProHint =
      'Modifie chaque partie de ta vitrine séparément.';
  static const menuVitrine = 'Vitrine & identité';
  static const menuVitrineHint =
      'Photo, salon, nom affiché, description, expérience';
  static const menuLocation = 'Adresse & lieu de travail';
  static const menuLocationHint = 'Adresse, code postal, ville, déplacements';
  static const menuServices = 'Services & tarifs';
  static const menuServicesHint = 'Ajouter, modifier ou supprimer des services';
  static const menuGallery = 'Photos de réalisations';
  static const menuGalleryHint = 'Portfolio visible par les clientes';
  static const editVitrine = 'Modifier la vitrine';
  static const editLocation = 'Modifier l’adresse';
  static const editServices = 'Modifier les services';
  static const editGallery = 'Modifier les réalisations';
  static const horaires = 'Mes horaires';
  static const menuHorairesHint = 'Créneaux et indisponibilités';
  static const publicFiche = 'Voir ma fiche publique';
  static const sectionAccount = 'Compte';
  static String servicesCount(int n) =>
      n <= 1 ? '$n service' : '$n services';
  static String specialtiesCount(int n) =>
      n <= 1 ? '$n spécialité' : '$n spécialités';
}
