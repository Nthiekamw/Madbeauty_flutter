/// Formulaire onboarding / édition profil prestataire.
abstract final class DiscPrestaForm {
  DiscPrestaForm._();

  static const intro =
      'Complète ton profil professionnel pour apparaître dans le catalogue client.';
  static const stepBasics = 'Vitrine & salon';
  static const stepLocation = 'Adresse & lieu';
  static const stepServices = 'Mes services';
  static const stepGallery = 'Réalisations';
  static const stepComfort = 'Confort & conditions';
  static const stepHoraires = 'Horaires';
  static const skipStep = 'Passer';
  static const completeLater = 'Configurer plus tard';
  static const completeLaterSaved =
      'Brouillon enregistré. Tu pourras reprendre la complétion de ton profil à tout moment.';
  static String hubWizardProgressLabel(int current, int total) =>
      'Étape $current sur $total';
  static const onboardingFinishCompleteTitle = 'Profil enregistré';
  static const onboardingFinishIncompleteTitle =
      'Profil enregistré — encore à compléter';
  static const onboardingFinishIncompleteBodyOk =
      'Tu peux apparaître dans le catalogue. Pour un profil plus attractif, pense à compléter :';
  static const onboardingFinishIncompleteBodyRequired =
      'Certaines informations obligatoires manquent encore pour être visible dans le catalogue :';
  static const onboardingFinishRequiredHeading = 'À compléter en priorité';
  static const onboardingFinishOptionalHeading = 'Recommandé';
  static const onboardingFinishLater = 'Plus tard';
  static const onboardingFinishCompleteCta = 'Compléter mon profil';
  static const onboardingFinishEnrichCta = 'Enrichir mon profil';
  static const avatarLabel = 'Photo de profil';
  static const avatarPick = 'Choisir une photo';
  static const avatarChange = 'Changer la photo';
  static const salonName = 'Nom du salon / activité';
  static const displayName = 'Nom affiché';
  static const displayNameHint = 'Visible par les clientes';
  static const bio = 'Présentation';
  static const bioHint = 'Texte libre complémentaire';
  static const description = 'Description';
  static const descriptionHint = '200 caractères max — accroche pour le catalogue';
  static const experienceYears = 'Années d’expérience';
  static const experiencePro = 'Expérience professionnelle';
  static const experienceProHint = '150 caractères max';
  static const experienceProSuggestionsLabel = 'Suggestions';
  static const experienceYearsSuggestionsLabel = 'Durée d’activité';

  static const experienceProSuggestions = <String>[
    'Coiffeuse / coiffeur indépendant·e',
    'Salon de coiffure',
    'Spécialiste tresses & locks',
    'Maquilleuse professionnelle',
    'Esthéticienne',
    'Prothésiste ongles',
    'Mise en beauté & soins',
  ];

  static const experienceYearsSuggestions = <String>[
    'Débutante',
    'Moins de 1 an',
    '1 à 2 ans',
    '3 à 5 ans',
    '5 à 10 ans',
    'Plus de 10 ans',
  ];
  static const city = 'Ville';
  static const postalCode = 'Code postal';
  static const postalCodeHint = 'ex. 75000';
  static const salonAddress = 'Adresse';
  static const salonAddressHint = 'Salon ou domicile — numéro et rue';
  static const workLocationTitle = 'Où travaillez-vous ?';
  static const workLocationHome = 'À mon domicile';
  static const workLocationClient = 'Chez la cliente';
  static const workLocationBoth = 'Les deux';
  static const specialtiesHint =
      'Choisis un ou plusieurs types de services proposés.';
  static const catalogIntro =
      'Sélectionne les services que tu proposes, puis précise tes spécialités '
      'pour chaque activité. Tu pourras affiner tes tarifs ensuite.';
  static const catalogMainTitle = 'Tes activités';
  static const catalogSpecialtiesHint =
      'Choisis au moins une spécialité, ou ajoute la tienne.';
  static String catalogSpecialtiesTitle(String serviceName) =>
      'Spécialités — $serviceName';
  static const catalogCustomHint = 'Autre spécialité';
  static const catalogCustomAdd = 'Ajouter';
  static const reqCatalogMain =
      'Sélectionne au moins un service (coiffure, manucure…).';
  static const reqCatalogSpecialty =
      'Choisis au moins une spécialité pour chaque service sélectionné.';
  static const pricingTitle = 'Tarifs & durée';
  static const pricingHint =
      'Indique le prix et la durée pour chaque prestation proposée.';
  static const pricingEmptyHint =
      'Sélectionne d’abord tes services et spécialités ci-dessus.';
  static const reqPricing =
      'Renseigne un prix valide (≥ 1 €) et une durée pour chaque prestation.';
  static const svcAdd = 'Ajouter un service';
  static const svcName = 'Nom du service';
  static const svcDescription = 'Description';
  static const svcCategory = 'Catégorie';
  static const svcCategoryPick = 'Choisir une catégorie';
  static const svcPrice = 'Prix (€)';
  static const svcDuration = 'Durée (min)';
  static const svcDelete = 'Supprimer ce service';
  static const suggestionTitle = 'Suggérer une catégorie';
  static const suggestionNom = 'Nom de la catégorie suggérée';
  static const suggestionDesc = 'Description';
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
  static const reqNameSalon = 'Saisis le nom de ton salon ou activité.';
  static const reqDisplayName = 'Saisis ton nom affiché.';
  static const reqPhoto = 'Ajoute une photo de profil.';
  static const reqDescription = 'Saisis une description.';
  static const reqCity = 'Saisis ta ville.';
  static const reqPostalCode = 'Saisis ton code postal.';
  static const reqAddress = 'Saisis ton adresse.';
  static const reqWorkLocation = 'Indique où tu travailles.';
  static const descriptionTooLong = '200 caractères maximum.';
  static const experienceProTooLong = '150 caractères maximum.';
  static const reqService = 'Configure au moins un service et une spécialité.';
  static const reqSvcName = 'Saisis le nom du service.';
  static const reqSvcCategory = 'Choisis une catégorie pour ce service.';
  static const svcPriceBad = 'Prix invalide.';
  static const svcDurationBad = 'Durée invalide.';
  static const saveErr =
      'Impossible d’enregistrer le profil. Vérifie ta connexion et réessaie.';
}
