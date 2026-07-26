/// Écran profil prestataire (onglet shell).
abstract final class DiscPrestaProfile {
  DiscPrestaProfile._();

  static const title = 'Profil';
  static const pageSubtitle =
      'Vitrine, horaires, fiche publique et compte.';
  static const editTitle = 'Profil professionnel';
  static const incompleteTitle = 'Profil incomplet';
  static const incompleteBody =
      'Complète ton salon : photo, bio, adresse, spécialités et services pour apparaître dans le catalogue.';
  static const incompleteCta = 'Compléter mon profil';
  static const editProfileHint = 'Modifier ma vitrine';
  static const sectionActivity = 'Mon activité';
  static const sectionPro = 'Gérer mon activité';
  static const sectionProHint =
      'Modifie chaque partie de ta vitrine séparément.';
  static const hubSectionTitle = 'Raccourcis';
  static const hubSalonTitle = 'Mon salon';
  static const hubSalonHint = 'Vitrine, services, galerie…';
  static const hubSalonScreenTitle = 'Mon salon';
  static const hubSalonScreenSubtitle =
      'Modifie chaque bloc de ta fiche publique.';
  static const hubBoutiqueTitle = 'Boutique';
  static const hubBoutiqueHint = 'Produits, packs, commandes';
  static const hubBoutiqueScreenTitle = 'Boutique';
  static const hubBoutiqueScreenSubtitle =
      'Gère ton catalogue et tes commandes produits.';
  static const hubReelsTitle = 'Reels';
  static const hubReelsHint = 'Photos et vidéos';
  static const hubHorairesTitle = 'Horaires';
  static const hubHorairesHint = 'Créneaux et congés';
  static const hubAvisTitle = 'Avis';
  static const hubAvisHint = 'Retours clientes';
  static const hubCompteTitle = 'Compte';
  static const hubCompteHint = 'Réglages et sécurité';
  static const hubCompteScreenTitle = 'Compte';
  static const hubCompteScreenSubtitle =
      'Apparence, notifications et paramètres du compte.';
  static const menuVitrine = 'Vitrine & identité';
  static const menuVitrineHint =
      'Photo, salon, nom affiché, description, expérience';
  static const menuLocation = 'Adresse & lieu de travail';
  static const menuLocationHint = 'Adresse, code postal, ville, déplacements';
  static const menuServices = 'Services & tarifs';
  static const menuServicesHint = 'Ajouter, modifier ou supprimer des services';
  static const menuGallery = 'Photos de réalisations';
  static const menuGalleryHint = 'Portfolio visible par les clientes (optionnel)';
  static const editVitrine = 'Modifier la vitrine';
  static const editLocation = 'Modifier l’adresse';
  static const editServices = 'Modifier les services';
  static const editGallery = 'Modifier les réalisations';
  static const horaires = 'Mes horaires';
  static const menuHorairesHint = 'Créneaux et indisponibilités';
  static const publicFiche = 'Voir ma fiche publique';
  static const publicFicheHint =
      'Aperçu tel que les clientes voient ton salon';
  static const sectionBio = 'À propos';
  static const sectionSpaceHint =
      'Basculer entre espace cliente et prestataire';
  static const sectionAccount = 'Compte';
  static const sectionAccountHint = 'E-mail connecté à MadBeauty';
  static const statServices = 'Services';
  static const statLikes = 'Likes';
  static const statSpecialties = 'Spécialités';
  static const statPhotos = 'Réalisations';
  static String servicesCount(int n) =>
      n <= 1 ? '$n service' : '$n services';
  static String specialtiesCount(int n) =>
      n <= 1 ? '$n spécialité' : '$n spécialités';
}
