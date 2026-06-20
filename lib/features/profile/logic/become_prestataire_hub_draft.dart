import '../../prestataire/models/horaire_day_draft.dart';

/// Snapshot local du formulaire hub (étape 2 « devenir prestataire »).
class BecomePrestataireHubDraft {
  const BecomePrestataireHubDraft({
    this.currentStep = 0,
    this.nomSalon = '',
    this.nomAffiche = '',
    this.bio = '',
    this.description = '',
    this.experienceProfessionnelle = '',
    this.anneesExperience = '',
    this.ville = '',
    this.codePostal = '',
    this.adresse = '',
    this.pays = 'FR',
    this.lieuTravail,
    this.avatarUrl,
    this.suggestionCategorieNom = '',
    this.suggestionCategorieDescription = '',
    this.confortClient = const [],
    this.conditionsService = const [],
    this.services = const [],
    this.horaires = const [],
    this.catalogSelection,
  });

  final int currentStep;
  final String nomSalon;
  final String nomAffiche;
  final String bio;
  final String description;
  final String experienceProfessionnelle;
  final String anneesExperience;
  final String ville;
  final String codePostal;
  final String adresse;
  final String pays;
  final String? lieuTravail;
  final String? avatarUrl;
  final String suggestionCategorieNom;
  final String suggestionCategorieDescription;
  final List<String> confortClient;
  final List<String> conditionsService;
  final List<BecomePrestataireHubServiceDraft> services;
  final List<HoraireDayDraft> horaires;
  final Map<String, dynamic>? catalogSelection;

  bool get hasContent =>
      currentStep > 0 ||
      nomSalon.trim().isNotEmpty ||
      nomAffiche.trim().isNotEmpty ||
      bio.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      ville.trim().isNotEmpty ||
      services.isNotEmpty ||
      confortClient.isNotEmpty ||
      horaires.any((h) => h.enabled);

  Map<String, dynamic> toJson() => {
        'currentStep': currentStep,
        'nomSalon': nomSalon,
        'nomAffiche': nomAffiche,
        'bio': bio,
        'description': description,
        'experienceProfessionnelle': experienceProfessionnelle,
        'anneesExperience': anneesExperience,
        'ville': ville,
        'codePostal': codePostal,
        'adresse': adresse,
        'pays': pays,
        if (lieuTravail != null) 'lieuTravail': lieuTravail,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'suggestionCategorieNom': suggestionCategorieNom,
        'suggestionCategorieDescription': suggestionCategorieDescription,
        'confortClient': confortClient,
        'conditionsService': conditionsService,
        'services': services.map((s) => s.toJson()).toList(),
        'horaires': horaires.map((h) => h.toJson()).toList(),
        if (catalogSelection != null) 'catalogSelection': catalogSelection,
      };

  static BecomePrestataireHubDraft? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    final servicesRaw = json['services'];
    final services = <BecomePrestataireHubServiceDraft>[];
    if (servicesRaw is List) {
      for (final item in servicesRaw) {
        final parsed = BecomePrestataireHubServiceDraft.fromJson(item);
        if (parsed != null) services.add(parsed);
      }
    }
    final horairesRaw = json['horaires'];
    final horaires = <HoraireDayDraft>[];
    if (horairesRaw is List) {
      for (final item in horairesRaw) {
        final parsed = HoraireDayDraft.fromJson(item);
        if (parsed != null) horaires.add(parsed);
      }
    }
    return BecomePrestataireHubDraft(
      currentStep: json['currentStep'] as int? ?? 0,
      nomSalon: json['nomSalon'] as String? ?? '',
      nomAffiche: json['nomAffiche'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      description: json['description'] as String? ?? '',
      experienceProfessionnelle:
          json['experienceProfessionnelle'] as String? ?? '',
      anneesExperience: json['anneesExperience'] as String? ?? '',
      ville: json['ville'] as String? ?? '',
      codePostal: json['codePostal'] as String? ?? '',
      adresse: json['adresse'] as String? ?? '',
      pays: (json['pays'] as String?)?.trim().toUpperCase().isNotEmpty == true
          ? (json['pays'] as String).trim().toUpperCase()
          : 'FR',
      lieuTravail: json['lieuTravail'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      suggestionCategorieNom: json['suggestionCategorieNom'] as String? ?? '',
      suggestionCategorieDescription:
          json['suggestionCategorieDescription'] as String? ?? '',
      confortClient: (json['confortClient'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      conditionsService: (json['conditionsService'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      services: services,
      horaires: horaires,
      catalogSelection: json['catalogSelection'] is Map
          ? Map<String, dynamic>.from(json['catalogSelection'] as Map)
          : null,
    );
  }
}

class BecomePrestataireHubServiceDraft {
  const BecomePrestataireHubServiceDraft({
    this.id,
    this.nom = '',
    this.description = '',
    this.categorieId,
    this.prix = '0',
    this.duree = '60',
  });

  final String? id;
  final String nom;
  final String description;
  final String? categorieId;
  final String prix;
  final String duree;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'nom': nom,
        'description': description,
        if (categorieId != null) 'categorieId': categorieId,
        'prix': prix,
        'duree': duree,
      };

  static BecomePrestataireHubServiceDraft? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final json = Map<String, dynamic>.from(raw);
    return BecomePrestataireHubServiceDraft(
      id: json['id'] as String?,
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categorieId: json['categorieId'] as String?,
      prix: json['prix'] as String? ?? '0',
      duree: json['duree'] as String? ?? '60',
    );
  }
}

