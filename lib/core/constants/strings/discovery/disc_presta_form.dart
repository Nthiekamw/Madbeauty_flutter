/// Formulaire onboarding / édition profil prestataire.
abstract final class DiscPrestaForm {
  DiscPrestaForm._();

  static const intro =
      'Complète ton profil professionnel pour apparaître dans le catalogue client.';
  static const stepBasics = 'Infos de base';
  static const stepSpecialties = 'Spécialités';
  static const stepServices = 'Services';
  static const avatarLabel = 'Photo de profil';
  static const avatarPick = 'Choisir une photo';
  static const avatarChange = 'Changer la photo';
  static const salonName = 'Nom du salon / activité';
  static const bio = 'Bio';
  static const bioHint =
      'Présente ton style, ton expérience, tes prestations…';
  static const city = 'Ville';
  static const specialtiesHint =
      'Choisis un ou plusieurs types de services proposés.';
  static const svcAdd = 'Ajouter un service';
  static const svcName = 'Nom du service';
  static const svcPrice = 'Prix (€)';
  static const svcDuration = 'Durée (min)';
  static const svcDelete = 'Supprimer ce service';
  static const back = 'Retour';
  static const onward = 'Continuer';
  static const save = 'Enregistrer';
  static const saving = 'Enregistrement…';
  static const uploadingAvatar = 'Upload de la photo en cours…';
  static const savedToast = 'Profil professionnel enregistré.';
  static const loadErr =
      'Impossible de charger ton profil prestataire. Réessaie.';
  static const missingSupabase =
      'Supabase n’est pas configuré : impossible d’enregistrer ton profil.';
  static const reqNameSalon =
      'Saisis le nom de ton salon ou activité.';
  static const reqPhoto = 'Ajoute une photo de profil.';
  static const reqBio = 'Saisis une bio.';
  static const reqCity = 'Saisis ta ville.';
  static const bioTooLong =
      'La bio doit faire 300 caractères maximum.';
  static const reqSpecialty =
      'Sélectionne au moins une spécialité.';
  static const reqService = 'Ajoute au moins un service.';
  static const reqSvcName = 'Saisis le nom du service.';
  static const svcPriceBad = 'Prix invalide.';
  static const svcDurationBad = 'Durée invalide.';
  static const saveErr =
      'Impossible d’enregistrer le profil. Vérifie ta connexion et réessaie.';
}
