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
  static const stepSubscription = 'Abonnement';
  static const hubBadgeRequired = 'Obligatoire';
  static const hubBadgeRecommended = 'Recommandé';
  static const hubBadgeOptional = 'Optionnel';
  static const hubSectionIdentity = 'Photo & identité';
  static const hubSectionIdentityHint = 'Photo et noms affichés sur ta fiche';
  static const hubSectionPresentation = 'Présentation';
  static const hubSectionPresentationHint = 'Description et expérience';
  static const hubSectionLocation = 'Lieu & adresse';
  static const hubSectionLocationHint = 'Où les clientes te trouvent';
  static const hubSectionCatalog = '1. Prestations proposées';
  static const hubSectionCatalogHint = 'Sélectionne au moins une catégorie';
  static const catalogMainCategoriesLine =
      'Coiffure · Manucure · Maquillage · Pédicure';
  static const servicesWizardAssistantTitle = 'Assistant services';
  static const servicesWizardAssistantSubtitle =
      'Prestation → Spécialité → Tarifs & durées';
  static const hubSectionPricing = '2. Tarifs & durées';
  static const hubSectionPricingHint = 'Renseigne chaque service ajouté';
  static const servicesWizardStepPrestation = 'Prestation';
  static const servicesWizardStepSpecialty = 'Spécialité';
  static const servicesWizardStepPricing = 'Tarifs & durées';
  static const servicesWizardPickPrestationHint =
      'Choisis une activité pour commencer';
  static const servicesWizardPickSpecialtyHint =
      'Sélectionne une spécialité à configurer. Appuie sur ✕ pour la retirer.';
  static const servicesWizardPricingHint =
      'Indique le prix et la durée pour cette prestation';
  static const servicesWizardAnotherSpecialty = 'Autre spécialité';
  static const servicesWizardAnotherPrestation = 'Autre prestation';
  static String servicesWizardActivePrestation(String name) =>
      'Prestation : $name';
  static String servicesWizardActiveSpecialty(String name) =>
      'Spécialité : $name';
  static const servicesWizardConfiguredBadge = 'Configuré';
  static const hubGalleryHint =
      'Ajoute jusqu’à 10 photos et 3 courtes vidéos de tes meilleures prestations '
      '(JPEG, PNG, WebP, MP4 ou MOV) pour valoriser ton savoir-faire.';
  static const hubGalleryPick = 'Ajouter des photos';
  static const hubGalleryPickVideo = 'Ajouter une vidéo';
  static const hubGalleryMediaCount = 'médias';
  static const hubGalleryVideoBadge = 'Vidéo';
  static const hubGalleryEmpty = 'Aucun média pour l’instant.';
  static const hubGalleryUploading = 'Envoi des médias…';
  static const skipStep = 'Passer';
  static const completeLater = 'Configurer plus tard';
  static const completeLaterSaved =
      'Brouillon enregistré. Tu pourras reprendre la complétion de ton profil à tout moment.';
  static const completeLaterNeedsCore =
      'Complète au minimum la vitrine, l’adresse, tes services et tes horaires pour enregistrer ton profil. '
      'Ton brouillon local est conservé.';
  static String hubWizardProgressLabel(int current, int total) =>
      'Étape $current sur $total';
  static const hubGoalBasics =
      'Photo, nom du salon et nom affiché : ce que les clientes voient en premier.';
  static const hubGoalLocation =
      'Adresse, ville et lieu de travail pour te trouver sur la carte.';
  static const hubGoalServices =
      'Choisis tes prestations puis indique prix et durée pour chaque service.';
  static const hubGoalGallery =
      'Ajoute des photos de tes réalisations pour inspirer confiance.';
  static const hubGoalComfort =
      'Précise ton confort et tes conditions pour rassurer les clientes.';
  static const hubGoalHoraires =
      'Indique tes créneaux habituels pour recevoir des réservations.';
  static const hubGoalSubscription =
      'Active ton abonnement pour publier tes services dans le catalogue.';
  static const hubSectionWorkPlace = 'Où travailles-tu ?';
  static const hubSectionWorkPlaceHint =
      'Les clientes savent si tu les reçois chez toi, à domicile ou les deux.';
  static const hubSectionAddress = 'Adresse & localisation';
  static const hubSectionAddressHint = 'Ville, code postal et rue pour te trouver sur la carte.';
  static const hubTipBasics =
      'Une photo nette et un nom de salon clair augmentent les réservations.';
  static const hubTipLocation =
      'Vérifie l’adresse : elle sert à afficher ta fiche sur la carte.';
  static const hubTipServices =
      'Commence par 2–3 prestations bien définies, tu pourras en ajouter plus tard.';
  static const hubTipGallery =
      '3 à 5 photos suffisent pour démarrer. Tu peux passer cette étape et revenir plus tard.';
  static const hubTipComfort =
      'Ces détails rassurent les clientes (accès, ambiance, conditions).';
  static const hubTipHoraires =
      'Active au moins un jour avec des horaires cohérents. '
      'Les congés sont optionnels : tu peux les ajouter maintenant ou plus tard.';
  static const hubTipSubscription =
      'Sans abonnement actif, ton profil reste invisible dans le catalogue.';
  static String hubStepTip(int stepIndex) => switch (stepIndex) {
        0 => hubTipBasics,
        1 => hubTipLocation,
        2 => hubTipServices,
        3 => hubTipHoraires,
        4 => hubTipGallery,
        5 => hubTipComfort,
        _ => hubTipSubscription,
      };
  static const hubAvatarPickHint = 'Choisis une photo ou une illustration ci-dessous.';
  static const hubServicesProgressLabel = 'Prestations configurées';
  static const hubHorairesOpenDays = 'Jours ouverts cette semaine';
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
  static const pricingEmptySpecialtyHint =
      'Choisis au moins une spécialité pour chaque activité — les tarifs apparaîtront ici.';
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
  static const saveProfile =
      'Enregistrer mon profil';
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
