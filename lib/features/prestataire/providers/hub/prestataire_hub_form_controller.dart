import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/models/domain/availability/horaire_plage.dart';
import '../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../core/models/domain/user/lieu_travail.dart';
import '../../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';
import '../../../../services/supabase/storage/storage_service.dart';
import '../../../profile/logic/prestataire_hub_onboarding_draft.dart';
import '../../logic/prestataire_hub_constants.dart';
import '../../logic/prestataire_hub_save_pipeline.dart';
import '../../logic/prestataire_hub_validation.dart';
import '../../models/prestataire_profile_edit_section.dart';
import '../../models/prestataire_service_catalog_selection.dart';
import '../../models/prestataire_service_field_set.dart';
import '../../models/weekly_jour_horaire.dart';

/// État formulaire hub prestataire (contrôleurs, validation, brouillon).
class PrestataireHubFormController extends ChangeNotifier {
  PrestataireHubFormController({
    this.focusedSection,
    int? initialStep,
  }) : _currentStep = _resolveInitialStep(focusedSection, initialStep) {
    if (PrestataireHubOnboardingDraft.isActive) {
      _attachOnboardingDraftListeners();
    }
  }

  final PrestataireProfileEditSection? focusedSection;

  static int _resolveInitialStep(
    PrestataireProfileEditSection? section,
    int? initialStep,
  ) {
    if (section != null) return section.hubStepIndex;
    if (initialStep != null) {
      return initialStep.clamp(0, PrestataireHubConstants.wizardStepCount - 1);
    }
    return 0;
  }

  final nomController = TextEditingController();
  final nomAfficheController = TextEditingController();
  final descriptionController = TextEditingController();
  final experienceProController = TextEditingController();
  final anneesExperienceController = TextEditingController();
  final bioController = TextEditingController();
  final villeController = TextEditingController();
  final codePostalController = TextEditingController();
  final adresseController = TextEditingController();
  final suggestionNomController = TextEditingController();
  final suggestionDescController = TextEditingController();

  final services = <PrestataireServiceFieldSet>[];
  var catalogSelection = PrestataireServiceCatalogSelection();
  final selectedComfortIds = <String>{};
  final selectedConditionIds = <String>{};

  int _currentStep;
  int get currentStep => _currentStep;

  var hydrated = false;
  var saving = false;
  double? uploadProgress;
  LieuTravail? lieuTravail;
  Uint8List? avatarBytes;
  String? avatarFileName;
  String? avatarMimeType;
  String? avatarUrl;

  String? avatarError;
  String? nomError;
  String? nomAfficheError;
  String? descriptionError;
  String? experienceProError;
  String? villeError;
  String? codePostalError;
  String? adresseError;
  String? lieuTravailError;
  String? servicesError;
  String? pricingError;
  String? galleryError;
  List<PhotoRealisation> galleryPhotos = [];
  final pendingGallery = <StorageUploadFile>[];
  PrestataireProfileFormData? loadedData;

  final _hubDraftDebouncer = HubOnboardingDraftDebouncer();
  var hubDraftApplied = false;
  List<WeeklyJourHoraire>? horaireWeek;
  var horairesHydrated = false;
  var horairesFromDraft = false;
  String? horairesError;

  bool get shouldPersistHoraires =>
      focusedSection == null ||
      focusedSection == PrestataireProfileEditSection.horaires ||
      _currentStep == 3;

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setSaving(bool value) {
    saving = value;
    notifyListeners();
  }

  void setUploadProgress(double? value) {
    uploadProgress = value;
    notifyListeners();
  }

  void attachOnboardingIfNeeded() {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    unawaited(PrestataireHubOnboardingDraft.markStep2Started());
    _attachOnboardingDraftListeners();
  }

  void _attachOnboardingDraftListeners() {
    for (final c in _draftControllers) {
      c.addListener(_onOnboardingFieldChanged);
    }
  }

  void _detachOnboardingDraftListeners() {
    for (final c in _draftControllers) {
      c.removeListener(_onOnboardingFieldChanged);
    }
  }

  List<TextEditingController> get _draftControllers => [
    nomController,
    nomAfficheController,
    descriptionController,
    experienceProController,
    anneesExperienceController,
    bioController,
    villeController,
    codePostalController,
    adresseController,
    suggestionNomController,
    suggestionDescController,
  ];

  void _onOnboardingFieldChanged() => _schedulePersistHubDraft();

  void _schedulePersistHubDraft() {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    _hubDraftDebouncer.schedule(_persistOnboardingHubDraft);
  }

  Future<void> persistHubDraftOnExit() async {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    try {
      await _persistOnboardingHubDraftUnchecked();
    } catch (_) {
      // Brouillon local : ne pas bloquer la navigation.
    }
  }

  Future<void> _persistOnboardingHubDraft() => persistHubDraftOnExit();

  Future<void> _persistOnboardingHubDraftUnchecked() async {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    final step = focusedSection?.hubStepIndex ?? _currentStep;
    await PrestataireHubOnboardingDraft.persist(
      currentStep: step,
      nomSalon: nomController.text,
      nomAffiche: nomAfficheController.text,
      bio: bioController.text,
      description: descriptionController.text,
      experienceProfessionnelle: experienceProController.text,
      anneesExperience: anneesExperienceController.text,
      ville: villeController.text,
      codePostal: codePostalController.text,
      adresse: adresseController.text,
      lieuTravail: lieuTravail,
      avatarUrl: avatarUrl,
      suggestionCategorieNom: suggestionNomController.text,
      suggestionCategorieDescription: suggestionDescController.text,
      confortClient: selectedComfortIds,
      conditionsService: selectedConditionIds,
      services: services,
      horaireWeek: horaireWeek,
    );
  }

  void maybeApplyOnboardingHubDraft() {
    if (hubDraftApplied || !PrestataireHubOnboardingDraft.isActive) return;
    final hub = PrestataireHubOnboardingDraft.readHub();
    if (hub == null) return;

    PrestataireHubOnboardingDraft.applyHubDraft(
      hub: hub,
      setCurrentStep: (step) {
        if (focusedSection == null) {
          _currentStep = step.clamp(0, PrestataireHubConstants.wizardStepCount - 1);
        }
      },
      nomController: nomController,
      nomAfficheController: nomAfficheController,
      bioController: bioController,
      descriptionController: descriptionController,
      experienceProController: experienceProController,
      anneesExperienceController: anneesExperienceController,
      villeController: villeController,
      codePostalController: codePostalController,
      adresseController: adresseController,
      setLieuTravail: (value) => lieuTravail = value,
      setAvatarUrl: (url) => avatarUrl = url,
      suggestionNomController: suggestionNomController,
      suggestionDescController: suggestionDescController,
      setComfortIds: (ids) {
        selectedComfortIds
          ..clear()
          ..addAll(ids);
      },
      setConditionIds: (ids) {
        selectedConditionIds
          ..clear()
          ..addAll(ids);
      },
      replaceServices: (list) {
        disposeServices();
        services.addAll(list);
      },
      setHoraireWeek: (week) {
        horaireWeek = week;
        horairesHydrated = true;
        horairesFromDraft = true;
      },
    );
    hubDraftApplied = true;
    notifyListeners();
  }

  void prepareOnboardingDraftRestore() {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    PrestataireHubOnboardingDraft.seedBasicsFromBecomeDraft(
      nomController: nomController,
      villeController: villeController,
      bioController: bioController,
      nomAfficheController: nomAfficheController,
    );
    maybeApplyOnboardingHubDraft();
    if (!hubDraftApplied) {
      unawaited(_persistOnboardingHubDraft());
    }
  }

  @override
  void dispose() {
    if (PrestataireHubOnboardingDraft.isActive) {
      _detachOnboardingDraftListeners();
      unawaited(_persistOnboardingHubDraft());
    }
    _hubDraftDebouncer.dispose();
    for (final c in _draftControllers) {
      c.dispose();
    }
    disposeServices();
    super.dispose();
  }

  void disposeServices() {
    for (final service in services) {
      service.dispose();
    }
    services.clear();
  }

  void hydrate(PrestataireProfileFormData data, {bool force = false}) {
    if (hydrated && !force) return;
    loadedData = data;
    nomController.text = data.nomSalon;
    nomAfficheController.text = data.nomAffiche;
    descriptionController.text = data.description;
    experienceProController.text = data.experienceProfessionnelle;
    anneesExperienceController.text = data.anneesExperience;
    bioController.text = data.bio;
    villeController.text = data.ville;
    codePostalController.text = data.codePostal;
    adresseController.text = data.adresse;
    lieuTravail = data.lieuTravail;
    selectedComfortIds
      ..clear()
      ..addAll(data.confortClient);
    selectedConditionIds
      ..clear()
      ..addAll(data.conditionsService);
    suggestionNomController.text = data.suggestionCategorieNom;
    suggestionDescController.text = data.suggestionCategorieDescription;
    galleryPhotos = List<PhotoRealisation>.from(data.realisationPhotos);
    avatarUrl = data.avatarUrl;
    avatarBytes = null;
    avatarFileName = null;
    avatarMimeType = null;
    catalogSelection = PrestataireServiceCatalogSelection.fromProfileData(
      selectedCategoryIds: data.selectedCategoryIds,
      services: data.services,
      legacySuggestionLabels: data.customSpecialtyLabels,
    );
    disposeServices();
    for (final service in data.services) {
      services.add(PrestataireServiceFieldSet.fromData(service));
    }
    hydrated = true;
    if (!force) {
      prepareOnboardingDraftRestore();
    }
    notifyListeners();
  }

  void ensureHoraireWeek(List<HorairePlage> plages) {
    if (horairesHydrated) return;
    horaireWeek = WeeklyJourHoraire.fromPlages(plages);
    horairesHydrated = true;
    notifyListeners();
  }

  void applyFieldErrors(PrestataireHubFieldErrors errors) {
    avatarError = errors.avatarError;
    nomError = errors.nomError;
    nomAfficheError = errors.nomAfficheError;
    descriptionError = errors.descriptionError;
    experienceProError = errors.experienceProError;
    villeError = errors.villeError;
    codePostalError = errors.codePostalError;
    adresseError = errors.adresseError;
    lieuTravailError = errors.lieuTravailError;
    servicesError = errors.servicesError;
    pricingError = errors.pricingError;
    galleryError = errors.galleryError;
    horairesError = errors.horairesError;
    notifyListeners();
  }

  PrestataireHubFieldErrors _validateVitrineFields() {
    return PrestataireHubValidation.validateVitrine(
      nom: nomController.text.trim(),
      nomAffiche: nomAfficheController.text.trim(),
      description: descriptionController.text.trim(),
      experiencePro: experienceProController.text.trim(),
      hasAvatar:
          avatarBytes != null ||
          (avatarUrl != null && avatarUrl!.trim().isNotEmpty),
    );
  }

  PrestataireHubFieldErrors _validateLocationFields() {
    return PrestataireHubValidation.validateLocation(
      ville: villeController.text.trim(),
      codePostal: codePostalController.text.trim(),
      adresse: adresseController.text.trim(),
      hasLieuTravail: lieuTravail != null,
    );
  }

  PrestataireHubFieldErrors _validateHorairesFields() {
    return PrestataireHubValidation.validateHoraires(horaireWeek: horaireWeek);
  }

  PrestataireHubFieldErrors _validateServicesFields() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (catalogSelection.isValid &&
        (services.isEmpty ||
            services.length != catalogSelection.specialtyCount)) {
      syncServicesFromCatalog();
    }
    final result = PrestataireHubValidation.validateServices(
      catalogSelection: catalogSelection,
      services: services,
    );
    return PrestataireHubFieldErrors(
      servicesError: result.errors.servicesError,
      pricingError: result.errors.pricingError,
    );
  }

  bool validateVitrine() {
    final errors = _validateVitrineFields();
    applyFieldErrors(errors);
    return errors.vitrineValid;
  }

  bool validateLocation() {
    final errors = _validateLocationFields();
    applyFieldErrors(errors);
    return errors.locationValid;
  }

  bool validateHoraires() {
    final errors = _validateHorairesFields();
    applyFieldErrors(errors);
    return errors.horairesValid;
  }

  bool validateServices() {
    final errors = _validateServicesFields();
    applyFieldErrors(errors);
    return errors.servicesValid;
  }

  bool validateCurrentStep() {
    return PrestataireHubValidation.validateCurrentStep(
      focusedSection: focusedSection,
      currentStep: _currentStep,
      validateVitrineFn: _validateVitrineFields,
      validateLocationFn: _validateLocationFields,
      validateServicesFn: _validateServicesFields,
      validateHorairesFn: _validateHorairesFields,
      applyErrors: applyFieldErrors,
    );
  }

  int? firstMandatoryStepFailure() {
    return PrestataireHubValidation.firstMandatoryStepFailure(
      validateVitrineFn: _validateVitrineFields,
      validateLocationFn: _validateLocationFields,
      validateServicesFn: _validateServicesFields,
      validateHorairesFn: _validateHorairesFields,
      applyErrors: applyFieldErrors,
    );
  }

  void syncServicesFromCatalog() {
    PrestataireHubSavePipeline.syncServicesFromCatalog(
      services: services,
      catalogSelection: catalogSelection,
    );
    notifyListeners();
  }

  PrestataireProfileSavePayload buildSavePayload() {
    return PrestataireHubSavePipeline.buildSavePayload(
      nomSalon: nomController.text.trim(),
      nomAffiche: nomAfficheController.text.trim(),
      bio: bioController.text.trim(),
      description: descriptionController.text.trim(),
      experienceProfessionnelle: experienceProController.text.trim(),
      anneesExperience: anneesExperienceController.text.trim(),
      ville: villeController.text.trim(),
      adresse: adresseController.text.trim(),
      codePostal: codePostalController.text.trim(),
      lieuTravail: lieuTravail ?? loadedData?.lieuTravail ?? LieuTravail.both,
      avatarBytes: avatarBytes,
      avatarFileName: avatarFileName,
      avatarMimeType: avatarMimeType,
      avatarUrl: avatarUrl,
      services: services,
      catalogSelection: catalogSelection,
      suggestionCategorieNom: suggestionNomController.text.trim(),
      suggestionCategorieDescription: suggestionDescController.text.trim(),
      confortClient: selectedComfortIds.toList(),
      conditionsService: selectedConditionIds.toList(),
    );
  }

  void clearBasicsErrors() {
    avatarError = null;
    nomError = null;
    nomAfficheError = null;
    descriptionError = null;
    experienceProError = null;
    villeError = null;
    codePostalError = null;
    adresseError = null;
    lieuTravailError = null;
    notifyListeners();
  }

  void setLieuTravail(LieuTravail value) {
    lieuTravail = value;
    lieuTravailError = null;
    notifyListeners();
    _schedulePersistHubDraft();
  }

  void setAvatarFromUpload({
    required Uint8List bytes,
    String? fileName,
    String? mimeType,
  }) {
    avatarBytes = bytes;
    avatarFileName = fileName;
    avatarMimeType = mimeType;
    avatarError = null;
    notifyListeners();
    _schedulePersistHubDraft();
  }

  void setAvatarError(String message) {
    avatarError = message;
    notifyListeners();
  }

  void selectDefaultAvatar(String url) {
    avatarUrl = url;
    avatarBytes = null;
    avatarFileName = null;
    avatarMimeType = null;
    avatarError = null;
    notifyListeners();
    _schedulePersistHubDraft();
  }

  void setGalleryError(String? message) {
    galleryError = message;
    notifyListeners();
  }

  void clearGalleryError() {
    if (galleryError == null) return;
    galleryError = null;
    notifyListeners();
  }

  void addPendingGallery(StorageUploadFile file) {
    pendingGallery.add(file);
    galleryError = null;
    notifyListeners();
  }

  void removePendingGalleryAt(int index) {
    pendingGallery.removeAt(index);
    galleryError = null;
    notifyListeners();
  }

  void removeGalleryPhoto(PhotoRealisation photo) {
    galleryPhotos = galleryPhotos.where((p) => p.id != photo.id).toList();
    notifyListeners();
  }

  void toggleComfort(String id) {
    if (selectedComfortIds.contains(id)) {
      selectedComfortIds.remove(id);
    } else {
      selectedComfortIds.add(id);
    }
    notifyListeners();
    _schedulePersistHubDraft();
  }

  void toggleCondition(String id) {
    if (selectedConditionIds.contains(id)) {
      selectedConditionIds.remove(id);
    } else {
      selectedConditionIds.add(id);
    }
    notifyListeners();
    _schedulePersistHubDraft();
  }

  void addCustomComfort(String encodedId) {
    if (!selectedComfortIds.contains(encodedId)) {
      selectedComfortIds.add(encodedId);
      notifyListeners();
      _schedulePersistHubDraft();
    }
  }

  void addCustomCondition(String encodedId) {
    if (!selectedConditionIds.contains(encodedId)) {
      selectedConditionIds.add(encodedId);
      notifyListeners();
      _schedulePersistHubDraft();
    }
  }

  void onCatalogChanged() {
    servicesError = null;
    pricingError = null;
    syncServicesFromCatalog();
  }

  void onPricingChanged() {
    pricingError = null;
    notifyListeners();
  }

  void toggleHoraireDay(int index, bool enabled) {
    final jours = horaireWeek;
    if (jours == null) return;
    jours[index].enabled = enabled;
    horairesError = null;
    notifyListeners();
    _schedulePersistHubDraft();
  }

  void updateHoraireTime(int index, bool isStart, TimeOfDay picked) {
    final jours = horaireWeek;
    if (jours == null) return;
    if (isStart) {
      jours[index].debut = picked;
    } else {
      jours[index].fin = picked;
    }
    horairesError = null;
    notifyListeners();
    _schedulePersistHubDraft();
  }

  void setCapacite(int index, int capacite) {
    final jours = horaireWeek;
    if (jours == null) return;
    jours[index].capaciteSimultanee = capacite;
    horairesError = null;
    notifyListeners();
    _schedulePersistHubDraft();
  }

  void setHorairesError(String? message) {
    horairesError = message;
    notifyListeners();
  }

  /// Avance d'une étape wizard si la validation passe. Retourne `true` si save demandé.
  bool advanceWizardStep() {
    if (focusedSection != null) return true;
    final step = _currentStep;
    if (step == 0) {
      if (!validateVitrine()) return false;
      _currentStep = 1;
    } else if (step == 1) {
      if (!validateLocation()) return false;
      _currentStep = 2;
    } else if (step == 2) {
      if (!validateServices()) return false;
      _currentStep = 3;
    } else if (step == 3) {
      if (!validateHoraires()) return false;
      _currentStep = 4;
    } else if (step == 4) {
      _currentStep = 5;
    } else if (step == 5) {
      _currentStep = 6;
    } else if (step == 6) {
      notifyListeners();
      return true;
    }
    notifyListeners();
    unawaited(_persistOnboardingHubDraft());
    return false;
  }

  void cancelWizardStep() {
    if (_currentStep == 0) return;
    _currentStep -= 1;
    notifyListeners();
    unawaited(_persistOnboardingHubDraft());
  }

  bool skipWizardStep() {
    if (focusedSection != null) return false;
    final step = _currentStep;
    if (step < PrestataireHubConstants.optionalFromStep) return false;
    if (step >= PrestataireHubConstants.wizardStepCount - 1) return true;
    _currentStep += 1;
    notifyListeners();
    unawaited(_persistOnboardingHubDraft());
    return false;
  }
}
